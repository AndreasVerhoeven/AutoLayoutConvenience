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
	private(set) var items = [Item]()
	private var notificationCookie: NSObjectProtocol?
	
	init(view: UIView) {
		self.view = view
	}
	
	internal func add(_ list: ConstraintsList, condition: UIView.Condition) {
		items.append(Item(list: list, condition: condition))
	}
	
	internal func merge(with other: ConstraintsListCollection) {
		items.append(contentsOf: other.items)
	}
	
	public func update() {
		guard let view = view else { return }
		var listsToDeactivate = [ConstraintsList]()
		var listsToActivate = [ConstraintsList]()
		
		for item in items {
			if item.condition.matches(for: view) == true {
				listsToActivate.append(item.list)
			} else {
				listsToDeactivate.append(item.list)
			}
		}
		
		NSLayoutConstraint.deactivate(listsToDeactivate.flatMap(\.all))
		NSLayoutConstraint.activate(listsToActivate.flatMap(\.all))
	}
	
	internal func installTraitCollectionObserverIfNeeded() {
		guard notificationCookie == nil else { return }
		guard let view = view else { return }
		UIView.swizzleTraitCollectionDidChangeIfNeeded()
		notificationCookie = NotificationCenter.default.addObserver(forName: UIView.traitCollectionDidChange, object: view, queue: .main, using: { [weak self] _ in
			self?.update()
		})
	}
	
	struct Item {
		var list: ConstraintsList
		var condition: UIView.Condition
	}
}
