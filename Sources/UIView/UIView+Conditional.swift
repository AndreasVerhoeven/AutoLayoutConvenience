//
//  UIView+Conditional.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 20/05/2022.
//

import UIKit
import ObjectiveC.runtime

extension UIView {
	fileprivate static var ConstraintCollectionListKey = 0
	fileprivate var constraintsListCollection: ConstraintsListCollection? {
		get { objc_getAssociatedObject(self, &Self.ConstraintCollectionListKey) as? ConstraintsListCollection }
		set { objc_setAssociatedObject(self, &Self.ConstraintCollectionListKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
	
	func `if`(is condition: Condition, callback: () -> Void, `else` elseCallback: () -> Void = {}) {
		Self.if(view: self, is: condition, callback: callback, else: elseCallback)
	}
	
	static func `if`(view: UIView, is condition: Condition, callback: () -> Void, `else` elseCallback: () -> Void = {}) {
		let collection = view.constraintsListCollection ?? ConstraintsListCollection(view: view)
		UIView.ignoreSpuriousAddSubviewForAutoLayoutCalls {
			ConstraintsList.intercept({ list, view in collection.add(list, condition: condition) }, while: callback)
			ConstraintsList.intercept( { list, view in collection.add(list, condition: condition.isFalse) }, while: elseCallback)
			view.constraintsListCollection = collection
			collection.installTraitCollectionObserverIfNeeded()
			collection.update()
		}
	}
	
	static func `if`(is condition: Condition, callback: () -> Void, `else` elseCallback: () -> Void = {}) {
		var collections = [UIView: ConstraintsListCollection]()
		
		func interceptor(for condition: Condition) -> ConstraintsList.Interceptor {
			return { list, view in
				let collection = collections[view] ?? view.constraintsListCollection ?? ConstraintsListCollection(view: view)
				collections[view] = collection
				collection.add(list, condition: condition)
			}
		}
		
		UIView.ignoreSpuriousAddSubviewForAutoLayoutCalls {
			ConstraintsList.intercept(interceptor(for: condition), while: callback)
			ConstraintsList.intercept(interceptor(for: condition.isFalse), while: elseCallback)
		}
		
		for (view, collection) in collections {
			objc_setAssociatedObject(view, &ConstraintCollectionListKey, collection, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			collection.installTraitCollectionObserverIfNeeded()
			collection.update()
		}
	}
}

extension UIView {
	public enum Condition {
		case containsTraits(in: UITraitCollection)
		indirect case not([Condition])
		indirect case and([Condition])
		indirect case or([Condition])
		
		static func vertical(is sizeClass: UIUserInterfaceSizeClass) -> Self { .containsTraits(in: .init(verticalSizeClass: sizeClass)) }
		static func horizontal(is sizeClass: UIUserInterfaceSizeClass) -> Self { .containsTraits(in: .init(horizontalSizeClass: sizeClass)) }
		
		static var verticallyCompact: Self { .vertical(is: .compact) }
		static var verticallyRegular: Self { .vertical(is: .regular) }
		
		static var horizontallyCompact: Self { .horizontal(is: .compact) }
		static var horizontallyRegular: Self { .horizontal(is: .regular) }
		
		var isTrue: Self { self }
		var isFalse: Self { .not([self]) }
		
		func matches(for view: UIView) -> Bool {
			switch self {
				case .containsTraits(in: let traits):
					return view.traitCollection.containsTraits(in: traits)
					
				case .not(let others):
					return others.contains { $0.matches(for: view) } == false
					
				case .and(let others):
					return others.allSatisfy { $0.matches(for: view) }
					
				case .or(let others):
					return others.contains { $0.matches(for: view) }
			}
		}
	}
}
