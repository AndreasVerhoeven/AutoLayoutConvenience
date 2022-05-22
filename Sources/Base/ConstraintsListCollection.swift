//
//  ConstraintsListCollection.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 20/05/2022.
//

import UIKit

/// A ConstraintsListCollection hold a collection of ConstraintsList
/// where only one of them is active. The collection (re)-evaluates the conditions
/// when needed and activates the correct set of constraints.
internal class ConstraintsListCollection: NSObject {
	private weak var view: UIView? // the view we are for, weak to not cause retain cycles.
	private var items = [Item]() // our items: being the conditions+lists
	private var notificationCookies = [NSObjectProtocol]() // registered observer cookies
	private var boundsObservers = [NSKeyValueObservation]() // registered bounds oberserves
	private var activeItemIds = Set<UUID>() // the list of ids of items that is active
	private var canDirectlyUpdate = false // true if we can do direct updates when something changes (we're not tracking complex conditions).
	private var needsUpdate = true // true if we need an update
	private var coalesceUpdates = true // true if we should coalesce updates if possible
	private var shouldAnimateUpdates = false // true if we should animate updates
	
	internal init(view: UIView) {
		self.view = view
	}
	
	/// re-evaluates all conditions and activates the right set of constraints.
	internal func update() {
		needsUpdate = false
		guard let view = view else { return }
		var listsToDeactivate = [ConstraintsList]()
		var listsToActivate = [ConstraintsList]()
		
		// iterate over each item and check if the condition matches: if it does, we need to activate
		// the constraints, otherwise deactivate.
		var newActiveItemIds = Set<UUID>()
		for item in items {
			if item.condition.matches(for: view) {
				newActiveItemIds.insert(item.id)
				listsToActivate.append(item.list)
			} else {
				listsToDeactivate.append(item.list)
			}
		}
		
		// keep track of the item ids that we want to activate and ensure they are different,
		// so we only update when there are actual changes.
		guard newActiveItemIds != activeItemIds else { return }
		activeItemIds = newActiveItemIds
		
		let updates = {
			NSLayoutConstraint.deactivate(listsToDeactivate.flatMap(\.all))
			NSLayoutConstraint.activate(listsToActivate.flatMap(\.all))
			
			// if we're in an animation block, force layout of the new constraints, so that
			// we animate those changes.
			if UIView.inheritedAnimationDuration > 0 {
				view.superview?.setNeedsLayout()
				view.superview?.layoutIfNeeded()
			}
		}
		
		// animate changes if we want, can and should.
		if shouldAnimateUpdates == true, view.window != nil, UIView.areAnimationsEnabled == true, UIView.inheritedAnimationDuration == 0 {
			UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: updates)
		} else {
			updates()
		}
	}
	
	/// adds a ConstraintsList with the given conditions that need to apply for it to become active.
	internal func add(_ list: ConstraintsList, conditions: [UIView.Condition]) {
		items.append(.init(list: list, condition: .all(conditions)))
	}
	
	/// Calls update when we are "dirty"
	internal func updateIfNeeded() {
		guard needsUpdate == true else { return }
		update()
	}
	
	/// stops coalescing updates: all updates will be directy.
	internal func stopCoalescingUpdates() {
		coalesceUpdates = false
	}
	
	/// will animate changes.
	internal func animateUpdates() {
		shouldAnimateUpdates = true
	}
	
	/// marks us as needing an update. An update can either happen directly or at the end of the current runloop, depending on settings and the complexity of the conditions.
	internal func setNeedsUpdate() {
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
	
	/// installs observers for all conditions
	internal func install() {
		// first, remove the old conditions
		notificationCookies.removeAll()
		boundsObservers.removeAll()
		
		// next, ask all our conditions for the views we need to monitor for traits and the views we need to monitor for bounds
		let traitsViews = viewsNeedingObservers(isForTraits: true)
		let boundsViews = viewsNeedingObservers(isForTraits: false)
		
		// if there's only one observer, we can always update directly since there's nothing to coalesce. We call these "simple" conditions, as opposed
		// to "complex" conditions.
		canDirectlyUpdate = (traitsViews.count + boundsViews.count) == 1
		
		// register trait observers
		UIView.swizzleTraitCollectionDidChangeIfNeeded()
		for view in traitsViews {
			notificationCookies.append(NotificationCenter.default.addObserver(forName: UIView.traitCollectionDidChange, object: view, queue: .main, using: { [weak self] notification in
				self?.setNeedsUpdate()
			}))
		}

		// register bounds observers
		for view in boundsViews {
			boundsObservers.append(view.layer.observe(\CALayer.bounds, changeHandler: { [weak self] _, _ in
				self?.setNeedsUpdate()
			}))
		}
		
		// and update
		update()
	}
	
	/// returns the list of views that need to be observed
	private func viewsNeedingObservers(isForTraits: Bool) -> Set<UIView> {
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
