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
internal class ConstraintsListCollection: ConditionList<ConstraintsListCollection.Item> {
	internal struct Item: UIView.Condition.ItemProvider {
		var id = UUID()
		var list: ConstraintsList
		var condition: UIView.Condition
	}

	// the active configuration name
	internal var activeConfigurationName = UIView.Condition.ConfigurationName.main {
		didSet {
			guard activeConfigurationName != oldValue else { return }
			guard let view = view else { return }
			NotificationCenter.default.post(name: Self.activeConfigurationNameDidChange, object: view)
		}
	}

	/// adds a ConstraintsList with the given conditions that need to apply for it to become active.
	internal func add(_ list: ConstraintsList, conditions: [UIView.Condition]) {
		items.append(.init(list: list, condition: .all(conditions)))
	}

	override internal func applyUpdates(_ activeItems: [Item], inactiveItems: [Item], view: UIView, animated: Bool) {
		NSLayoutConstraint.deactivate(inactiveItems.flatMap(\.list.all))
		NSLayoutConstraint.activate(activeItems.flatMap(\.list.all))

		// if we're in an animation block, force layout of the new constraints, so that
		// we animate those changes.
		if UIView.inheritedAnimationDuration > 0 {
			view.superview?.setNeedsLayout()
			view.superview?.layoutIfNeeded()
		}
	}
}

fileprivate extension ConstraintsListCollection {
	static var activeConfigurationNameDidChange = Notification.Name(rawValue: "com.aveapps.AutoLayoutConvenience.activeConfigurationNameDidChange")
}

internal extension UIView {
	func monitorActiveConfigurationName(_ callback: @escaping () -> Void) -> Cancellable {
		let observer = NotificationCenter.default.addObserver(forName: ConstraintsListCollection.activeConfigurationNameDidChange, object: self, queue: .main, using: { _ in callback() })
		return Cancellable(notificationCenterObserver: observer)
	}
}
