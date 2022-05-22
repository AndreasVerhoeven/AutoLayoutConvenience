//
//  ConstraintsListCollection.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 20/05/2022.
//

import UIKit

/// A ConstraintsListCollection hold a collection of ConstraintsList
/// where only one of them is active
public class ConstraintsListCollection: NSObject {
	private(set) weak var view: UIView?
	fileprivate var items = [Item]()
	private var notificationCookies = [NSObjectProtocol]()
	private var boundsObservers = [NSKeyValueObservation]()
	private var activeItemIds = Set<UUID>()
	private var canDirectlyUpdate = false
	private var needsUpdate = true
	private var coalesceUpdates = true
	private var shouldAnimateUpdates = false
	
	init(view: UIView) {
		self.view = view
	}
	
	public func update() {
		needsUpdate = false
		guard let view = view else { return }
		var listsToDeactivate = [ConstraintsList]()
		var listsToActivate = [ConstraintsList]()
		
		var newActiveItemIds = Set<UUID>()
		for item in items {
			if item.condition.matches(for: view) {
				newActiveItemIds.insert(item.id)
				listsToActivate.append(item.list)
			} else {
				listsToDeactivate.append(item.list)
			}
		}
		
		guard newActiveItemIds != activeItemIds else { return }
		activeItemIds = newActiveItemIds
		
		let updates = {
			NSLayoutConstraint.deactivate(listsToDeactivate.flatMap(\.all))
			NSLayoutConstraint.activate(listsToActivate.flatMap(\.all))
			if UIView.inheritedAnimationDuration > 0 {
				view.superview?.setNeedsLayout()
				view.superview?.layoutIfNeeded()
			}
		}
		
		if shouldAnimateUpdates == true, view.window != nil, UIView.areAnimationsEnabled == true, UIView.inheritedAnimationDuration == 0 {
			UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: updates)
		} else {
			updates()
		}
	}
	
	internal func add(_ list: ConstraintsList, conditions: [UIView.Condition]) {
		items.append(.init(list: list, condition: .all(conditions)))
	}
	
	func updateIfNeeded() {
		guard needsUpdate == true else { return }
		update()
	}
	
	func stopCoalescingUpdates() {
		coalesceUpdates = false
	}
	
	func animateUpdates() {
		shouldAnimateUpdates = true
	}
	
	func setNeedsUpdate() {
		if canDirectlyUpdate == true || coalesceUpdates == false {
			update()
		} else {
			needsUpdate = true
			
			let observer = CFRunLoopObserverCreateWithHandler(kCFAllocatorDefault, CFRunLoopActivity.beforeWaiting.rawValue, false, 0, { [weak self] observer, activity in
				self?.updateIfNeeded()
			})
			if observer != nil {
				CFRunLoopAddObserver(CFRunLoopGetMain(), observer, CFRunLoopMode.commonModes)
			}
		}
	}
	
	internal func start() {
		notificationCookies.removeAll()
		boundsObservers.removeAll()
		
		let traitsView = viewsNeedingObservers(isForTraits: true)
		let boundsViews = viewsNeedingObservers(isForTraits: false)
		canDirectlyUpdate = (traitsView.count + boundsViews.count) == 1
		
		UIView.swizzleTraitCollectionDidChangeIfNeeded()
		for view in traitsView {
			notificationCookies.append(NotificationCenter.default.addObserver(forName: UIView.traitCollectionDidChange, object: view, queue: .main, using: { [weak self] notification in
				self?.setNeedsUpdate()
			}))
		}

		for view in boundsViews {
			boundsObservers.append(view.layer.observe(\CALayer.bounds, changeHandler: { [weak self] _, _ in
				self?.setNeedsUpdate()
			}))
		}
		
		update()
	}
	
	internal func viewsNeedingObservers(isForTraits: Bool) -> Set<UIView> {
		guard let view = view else { return [] }
		return items.reduce(Set<UIView>()) { partialResult, item in
			return partialResult.union(item.condition.viewsNeedingObservers(isForTraits: isForTraits, view: view).compactMap({ $0 }))
		}
	}
}

extension ConstraintsListCollection {
	fileprivate struct Item {
		var id = UUID()
		var list: ConstraintsList
		var condition: UIView.Condition
	}
}
