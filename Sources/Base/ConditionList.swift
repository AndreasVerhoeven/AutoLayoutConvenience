//
//  ConditionList.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 14/08/2025.
//

import UIKit

extension UIView.Condition {
	protocol ConditionHandler {
		var coalesceUpdates: Bool { get }
		var shouldAnimateUpdates: Bool { get }

		func update()
		func updateIfNeeded()
		func stopCoalescingUpdates()
		func animateUpdates()
		func setNeedsUpdate()
	}
}

/// A ConstraintsListCollection hold a collection of ConstraintsList
/// where only one of them is active. The collection (re)-evaluates the conditions
/// when needed and activates the correct set of constraints.
internal class ConditionList<Item: UIView.Condition.ItemProvider>: NSObject, UIView.Condition.ConditionHandler {
	internal weak var view: UIView? // the view we are for, weak to not cause retain cycles.
	internal var items = [Item]() // our items: being the conditions+lists
	private var cancellables = [Cancellable]() // registered observers
	private var boundsObservers = [NSKeyValueObservation]() // registered bounds oberservers
	private var activeItemIds = Set<UUID>() // the list of ids of items that is active
	private(set) var canDirectlyUpdate = false // true if we can do direct updates when something changes (we're not tracking complex conditions).
	private(set) var needsUpdate = true // true if we need an update
	private(set) var coalesceUpdates = true // true if we should coalesce updates if possible
	private(set) var shouldAnimateUpdates = false // true if we should animate updates

	internal init(view: UIView) {
		self.view = view
	}

	internal func applyUpdates(_ activeItems: [Item], inactiveItems: [Item], view: UIView, animated: Bool) {
		// for subclasses to override
	}

	/// re-evaluates all conditions and activates the right set of constraints.
	internal func update() {
		needsUpdate = false
		guard let view = view else { return }

		var activeItems = [Item]()
		var inactiveItems = [Item]()

		// iterate over each item and check if the condition matches: if it does, we need to activate
		// the constraints, otherwise deactivate.
		var newActiveItemIds = Set<UUID>()
		for item in items {
			if item.condition.matches(for: view) {
				newActiveItemIds.insert(item.id)
				activeItems.append(item)
			} else {
				inactiveItems.append(item)
			}
		}

		// keep track of the item ids that we want to activate and ensure they are different,
		// so we only update when there are actual changes.
		guard newActiveItemIds != activeItemIds else { return }
		activeItemIds = newActiveItemIds

		// animate changes if we want, can and should.
		if shouldAnimateUpdates == true, view.window != nil, UIView.areAnimationsEnabled == true, UIView.inheritedAnimationDuration == 0 {
			UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
				self.applyUpdates(activeItems, inactiveItems: inactiveItems, view: view, animated: true)
			})
		} else {
			self.applyUpdates(activeItems, inactiveItems: inactiveItems, view: view, animated: false)
		}
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
		guard let view = view else { return }

		// first, remove the old conditions
		cancellables.removeAll()
		boundsObservers.removeAll()

		// next, ask all our conditions for the views we need to monitor for traits and the views we need to monitor for bounds
		var observers = [UIView: UIView.Condition.ObserverKind]()
		for item in items {
			item.condition.neededObservers(for: view).forEach {
				guard let view = $0.key else { return }
				observers[view, default: .none].formUnion($0.value)
			}
		}

		// if there's only one observer, we can always update directly since there's nothing to coalesce. We call these "simple" conditions, as opposed
		// to "complex" conditions.
		canDirectlyUpdate = observers.count <= 1 && observers.first?.value.hasSingleItem == true

		// register trait observers
		for (view, kind) in observers where kind.contains(.traits) {
			cancellables.append(view.monitorTraitCollectionChanges({ [weak self] in
				self?.setNeedsUpdate()
			}).automaticallyCancellingOnDeInit)
		}

		// register bounds observers
		for (view, kind) in observers where kind.contains(.bounds) {
			boundsObservers.append(view.layer.observe(\CALayer.bounds, options: [.new], changeHandler: { [weak self] _, _ in
				self?.setNeedsUpdate()
			}))
		}

		// register hidden observers
		for (view, kind) in observers where kind.contains(.hidden) {
			boundsObservers.append(view.observe(\UIView.isHidden, changeHandler: { [weak self] _, _ in
				self?.setNeedsUpdate()
			}))
		}

		// register name observers
		for (view, kind) in observers where kind.contains(.name) {
			cancellables.append(view.monitorActiveConfigurationName({ [weak self] in
				self?.setNeedsUpdate()
			}).automaticallyCancellingOnDeInit)
		}

		// and update
		update()
	}
}


internal extension UIView.Condition {
	protocol ItemProvider {
		var id: UUID { get }
		var condition: UIView.Condition { get }
	}

	struct ObserverKind: RawRepresentable, OptionSet {
		var rawValue: Int

		static let none = Self(rawValue: 0 << 0)
		static let traits = Self(rawValue: 1 << 0)
		static let bounds = Self(rawValue: 1 << 1)
		static let name = Self(rawValue: 1 << 2)
		static let hidden = Self(rawValue: 1 << 3)
		static let all: Self = [.traits, .bounds, .name, .hidden]

		var hasSingleItem: Bool {
			return self == .traits || self == .bounds || self == .name || self == .hidden
		}
	}
}
