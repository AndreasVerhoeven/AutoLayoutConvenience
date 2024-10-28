//
//  UIView+Condition.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 21/05/2022.
//

import UIKit

extension UIView {
	/// A condition for conditional constraints. Use one of the factory methods, you
	/// cannot create instances directly.
	/// Conditions come in two flavors:
	/// 	- specific  ones, where the condition should apply to a specific view
	///		- unspecific ones, where the condition applies to the view being constrained or added
	@MainActor public struct Condition {
		public typealias ViewEvaluator = (UIView) -> Bool
		public typealias NoViewEvaluator = () -> Bool
		
		/// we keep the actual condition kind private, so that people are forced to use our
		/// factory methods and we can change the internal implementation easily.
		fileprivate var kind: Kind
		fileprivate init(_ kind: Kind) {
			self.kind = kind
		}
	}
}

extension UIView.Condition {
	/// This is a name of a configuration. See `UIView.addNamedConditionalConfiguration(name:configuration:)`
	public struct ConfigurationName: RawRepresentable, Hashable, Sendable {
		public var rawValue: String
		
		public init(rawValue: String) {
			self.rawValue = rawValue
		}
		
		/// A predefined main configuration. This one is active by default.
		public static let main = ConfigurationName(rawValue: "main")
		/// A predefined alternative configuration name.
		public static let alternative = ConfigurationName(rawValue: "alternative")
		/// A predefined configuration name that can be used for configurations that are "shown".
		public static let visible = ConfigurationName(rawValue: "shown")
		/// A predefined configuration name that can be used for configurations that are "hidden".
		public static let hidden = ConfigurationName(rawValue: "hidden")
	}
}

public extension UIView.Condition {
	// MARK: - View
	
	/// A specific view needs to have a specific condition
	///
	/// - Parameters:
	///		- view: the view to apply the condition to
	///		- condition: the condition to check
	///
	///	- Returns: The created condition
	static func view(_ view: UIView, is condition: Self) -> Self {
		return .init(.bound(.init(view: view, kind: condition.kind)))
	}
	
	/// Alias of `view(is:)`
	///
	/// - Parameters:
	///		- view: the view to apply the condition to
	///		- condition: the condition to check
	///
	///	- Returns: The created condition
	static func view(_ view: UIView, has condition: Self) -> Self {
		return Self.view(view, is: condition)
	}
	
	/// A specific view needs to match a callback
	///
	/// - Parameters:
	///		- view: the view to apply the condition to
	///		- callback: the callback that will be called. Make sure to weakly retain any other views to avoid cycles. The view itself will be passed in.
	///
	///	- Returns: The created condition
	static func view(_ view: UIView, matches callback: @escaping ViewEvaluator) -> Self {
		return Self.view(view, is: .callback(callback))
	}
	
	/// A specific view needs to match all the given conditions
	///
	/// - Parameters:
	///		- view: the view to apply the condition to
	///		- conditions: the conditions that all need to match
	///
	///	- Returns: The created condition
	static func view(_ view: UIView, all conditions: [Self]) -> Self { Self.view(view, is: .all(conditions)) }
	
	/// A specific view needs to match all the given conditions
	///
	/// - Parameters:
	///		- view: the view to apply the condition to
	///		- conditions: the conditions that all need to match
	///
	///	- Returns: The created condition
	static func view(_ view: UIView, all conditions: Self...) -> Self { Self.view(view, all: conditions) }
	
	/// A specific view needs to match any of the given conditions
	///
	/// - Parameters:
	///		- view: the view to apply the condition to
	///		- conditions: the conditions of which only one need to match
	///
	///	- Returns: The created condition
	static func view(_ view: UIView, any conditions: [Self]) -> Self { Self.view(view, is: .any(conditions)) }
	
	/// A specific view needs to match any of the given conditions
	///
	/// - Parameters:
	///		- view: the view to apply the condition to
	///		- conditions: the conditions of which only one need to match
	///
	///	- Returns: The created condition
	static func view(_ view: UIView, any conditions: Self...) -> Self { Self.view(view, any: conditions) }
	
	
	/// A specific view needs to match the traits in a given collection
	///
	/// - Parameters:
	///		- view: the view to apply the condition to
	///		- traitCollection: the trait collection that needs to be contained in the view's trait collection
	///
	///	- Returns: The created condition
	static func view(_ view: UIView, hasTraitsIn traitCollection: UITraitCollection) -> Self {
		return Self.view(view, is: .traits(in: traitCollection))
	}
	
	/// A specific view needs a property in its trait collection to match a specific value
	///
	/// - Parameters:
	///		- view: the view to apply the condition to
	///		- keyPath: the property in the trait collection we want to match on
	///		- value: the value the property should have
	///
	///	- Returns: The created condition
	static func view<Value: Equatable>(_ view: UIView, has keyPath: KeyPath<UITraitCollection, Value>, is value: Value) -> Self {
		return Self.view(view, is: .trait(keyPath, is: value))
	}
	
	// MARK: - Size
	
	/// Matches when the width of the relevant view matches the given constraint. (e.g. width must be atLeast(200))
	///
	/// - Parameters:
	///		- width: the width to check for as a SizeConstrain.
	///
	///	- Returns: The created condition
	static func width(is width: SizeConstrain<CGFloat>) -> Self { .init(.width(width)) }
	
	/// Matches when the height of the relevant view matches the given constraint. (e.g. width must be atLeast(200))
	///
	/// - Parameters:
	///		- height: the height to check for as a SizeConstrain.
	///
	///	- Returns: The created condition
	static func height(is height: SizeConstrain<CGFloat>) -> Self { .init(.height(height)) }
	
	/// Matches when the width and height of the relevant view matches the given constraints.
	///
	/// - Parameters:
	///		- width: the width to check for as a SizeConstrain.
	///		- height: the height to check for as a SizeConstrain.
	///
	///	- Returns: The created condition
	static func width(is width: SizeConstrain<CGFloat>, heightIs height: SizeConstrain<CGFloat>) -> Self {
		return .init(.and([.width(width), .height(height)]))
	}
	
	/// Matches when both the width and height matches a given constraint.
	///
	/// - Parameters:
	///		- dimension: the width and height to check for as a SizeConstrain.
	///
	///	- Returns: The created condition
	static func widthAndHeight(is dimension: SizeConstrain<CGFloat>) -> Self {
		return .init(.and([.width(dimension), .height(dimension)]))
	}
	
	// MARK: - Name
	static func name(is name: ConfigurationName) -> Self { .init(.named(name)) }
	
	/// Matches when the traitCollection of the relevant view has the traits in the given trait collection.
	///
	/// - Parameters:
	///		- traitCollection: the trait collection that needs to be contained in the view's trait collection
	///
	///	- Returns: The created condition
	static func traits(in traitCollection: UITraitCollection) -> Self {
		return .init(.traits(in: traitCollection))
	}
	
	/// Matches when the relevant view's trait collection has a property with the given specific value
	///
	/// - Parameters:
	///		- keyPath: the property in the trait collection we want to match on
	///		- value: the value the property should have
	///
	///	- Returns: The created condition
	static func trait<Value: Equatable>(_ keyPath: KeyPath<UITraitCollection, Value>, is value: Value) -> Self {
		return .init(.specificTrait({ $0.traitCollection[keyPath: keyPath] == value }))
	}
	
	/// Matches when the vertical size class is compact
	static var verticallyCompact: Self { traits(in: UITraitCollection(verticalSizeClass: .compact)) }
	
	/// Matches when the vertical size class is regular
	static var verticallyRegular: Self { traits(in: UITraitCollection(verticalSizeClass: .regular)) }
	
	/// Matches when the horizontal size class is compact
	static var horizontallyCompact: Self { traits(in: UITraitCollection(horizontalSizeClass: .compact)) }
	
	/// Matches when the horizontal size class is regular
	static var horizontallyRegular: Self { traits(in: UITraitCollection(horizontalSizeClass: .regular)) }
	
	/// Matches when the relevant views idion is the given idiom
	static func idiom(_ idiom: UIUserInterfaceIdiom) -> Self { traits(in: UITraitCollection(userInterfaceIdiom: idiom))  }
	
	/// Matches when we are an iPhone
	static var phone: Self { idiom(.phone) }
	
	/// Matches when we are an iPad
	static var pad: Self { idiom(.pad) }
	
	/// Matches when we are an mac
	@available(iOS 14, *)
	static var mac: Self { idiom(.mac) }
	
	/// Matches when we are an tv
	static var tv: Self { idiom(.tv) }
	
	/// Matches when we are a carplay
	static var carPlay: Self { idiom(.carPlay) }
	
	@available(iOS 12, *)
	/// Matches when we are light style
	static var light: Self { traits(in: UITraitCollection(userInterfaceStyle: .light)) }
	
	@available(iOS 12, *)
	/// Matches when we are dark style
	static var dark: Self { traits(in: UITraitCollection(userInterfaceStyle: .dark)) }
	
	/// Matches when we are an left-to-right
	static var leftToRight: Self { traits(in: UITraitCollection(layoutDirection: .leftToRight)) }
	
	/// Matches when we are an right-to-left
	static var rightToLeft: Self { traits(in: UITraitCollection(layoutDirection: .rightToLeft)) }
	
	// MARK: - Visibility
	
	///  matches when the view is hidden
	static var hidden: Self { .init(.hidden) }
	
	/// matches when the view is not hidden
	static var visible: Self { .init(.hidden).isFalse }
	
	// MARK: - Callback
	
	/// Matches when the given callback returns true. The relevant view will be passed in as an argument.
	/// Be careful to not create retain cycles by capturing other views weakly. This will be retained by the relevant view.
	///
	/// - Parameters:
	///		- callback: will be called to evaluate this condition. Return true to match.
	///
	///	- Returns: The created condition
	static func callback( _ callback: @escaping ViewEvaluator) -> Self { .init(.callbackView(callback)) }
	
	/// Matches when the given callback returns true.
	/// Be careful to not create retain cycles by capturing other views weakly. This will be retained by the relevant view.
	///
	/// - Parameters:
	///		- callback: will be called to evaluate this condition. Return true to match.
	///
	///	- Returns: The created condition
	static func callback(_ callback: @escaping NoViewEvaluator) -> Self { .init(.callbackNoView(callback)) }
	
	// MARK: - All
	
	/// Matches when all passed in conditions match
	static func all(_ conditions: [Self]) -> Self { .init(.and(conditions.map(\.kind))) }
	
	/// Matches when all passed in conditions match
	static func all(_ conditions: Self...) -> Self { Self.all(conditions) }
	
	// MARK: - Any
	
	/// Matches when any of the passed in conditions match
	static func any(_ conditions: [Self]) -> Self { .init(.or(conditions.map(\.kind))) }
	
	/// Matches when any of the passed in conditions match
	static func any(_ conditions: Self...) -> Self { Self.any(conditions) }
	
	// MARK: - Not
	
	/// Matches when none of the passed in conditions match
	static func not(_ conditions: [Self]) -> Self { .init(.not(conditions.map(\.kind))) }
	
	/// Matches when none of the passed in conditions match
	static func not(_ conditions: Self...) -> Self { Self.not(conditions) }
	
	// MARK: - Constants
	
	static var alwaysTrue: Self { .init(.alwaysTrue) }
	static var alwaysFalse: Self { .init(.alwaysFalse) }
	
	// MARK: - Instance
	
	/// Expressive helper: simply returns self
	var isTrue: Self { self }
	
	/// Matches when this condition does not match
	var isFalse: Self { Self.not(self) }
	
	/// matches when this condition and the passed in conditions all match
	func and(_ other: Self...) -> Self { Self.all([self] + other) }
	
	/// matches when this condition or any of  the passed in conditions all match
	func or(_ other: Self...) -> Self { Self.any([self] + other) }
}

// MARK: - Private

extension UIView.Condition {
	@MainActor fileprivate enum Kind {
		@MainActor struct BoundCondition {
			weak var view: UIView?
			var kind: Kind
		}
		
		// size constraints
		case width(SizeConstrain<CGFloat>)
		case height(SizeConstrain<CGFloat>)
		
		// named
		case named(ConfigurationName)
		
		// traits
		case traits(in: UITraitCollection)
		case specificTrait(ViewEvaluator)
		
		// custom callback
		case callbackView(ViewEvaluator)
		case callbackNoView(NoViewEvaluator)
		
		// visibility
		case hidden
		
		// constants
		case alwaysTrue
		case alwaysFalse
		
		// combinations
		indirect case and([Kind])
		indirect case or([Kind])
		indirect case not([Kind])
		
		// bound to a view
		indirect case bound(BoundCondition)
	}
}

internal extension UIView.Condition {
	/// internal helpers
	func matches(for view: UIView) -> Bool { kind.matches(for: view) }
	func neededObservers(for view: UIView) -> [UIView?: ConstraintsListCollection.ObserverKind] { kind.neededObservers(for: view) }
	
	// bind this condition to a view if there is no view assigned bound yet.
	func bind(to view: UIView?) -> Self { Self(kind.bound(to: view)) }
}

fileprivate extension UIView.Condition.Kind {
	@MainActor func matches(for view: UIView) -> Bool {
		switch self {
			case .width(let sizeConstrain): return sizeConstrain.matches(for: view.bounds.width, scale: view.scaleToUse)
			case .height(let sizeConstrain): return sizeConstrain.matches(for: view.bounds.height, scale: view.scaleToUse)
				
			case .named(let name): return view.activeConditionalConstraintsConfigurationName == name
				
			case .traits(in: let traitCollection): return view.traitCollection.containsTraits(in: traitCollection)
			case .specificTrait(let evaluator): return evaluator(view)
			
			case .callbackView(let evaluator): return evaluator(view)
			case .callbackNoView(let evaluator): return evaluator()
				
			case .hidden: return view.isHidden
				
			case .alwaysTrue: return true
			case .alwaysFalse: return false
				
			case .and(let others): return others.allSatisfy { $0.matches(for: view) }
			case .or(let others): return others.contains { $0.matches(for: view) }
			case .not(let others): return others.contains { $0.matches(for: view) } == false
			case .bound(let boundCondition): return boundCondition.matches()
		}
	}
	
	func neededObservers(for view: UIView?) -> [UIView?: ConstraintsListCollection.ObserverKind] {
		switch self {
			case .width, .height: return [view: .bounds]
			case .traits, .specificTrait: return [view: .traits]
			case .named: return [view: .name]
			case .callbackView, .callbackNoView: return [view: .all]
			case .hidden: return [view: .hidden]
			case .alwaysTrue, .alwaysFalse: return [:]
			case .bound(let bounded): return bounded.kind.neededObservers(for: view)
			case .and(let others), .or(let others), .not(let others):
				var observers = [UIView?: ConstraintsListCollection.ObserverKind]()
				for other in others {
					other.neededObservers(for: view).forEach { observers[$0.key, default: .none].formUnion($0.value)  }
				}
				return observers
		}
	}

	
	func bound(to view: UIView?) -> Self {
		guard let view = view else { return self }
		if case Self.bound = self {
			return self
		} else {
			return .bound(.init(view: view, kind: self))
		}
	}
}

extension UIView.Condition.Kind.BoundCondition {
	func matches() -> Bool {
		return view.flatMap { kind.matches(for:$0) } ?? false
	}
}

extension SizeConstrain where T == CGFloat {
	fileprivate func matches(for value: T, scale: CGFloat) -> Bool {
		let scaledInputValue = Int(round((value * multiplier + constant) * scale))
		let scaledValue = Int(round(self.value * scale))
		
		switch type {
			case .atLeast: return scaledInputValue >= scaledValue
			case .exactly: return scaledInputValue == scaledValue
			case .atMost: return scaledInputValue <= scaledValue
		}
	}
}

extension UIView {
	fileprivate var scaleToUse: CGFloat {
		return window?.screen.scale ?? UIScreen.main.scale
	}
}
