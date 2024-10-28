//
//  ConstraintsList.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 23/04/2021.
//  Copyright © 2021 bunq. All rights reserved.
//

import UIKit

/// A ConstraintsList hold a list of constraints
/// that were created using one of our helper methods.
@MainActor public class ConstraintsList: NSObject {
	public weak var view: UIView?

	public var leading: NSLayoutConstraint?
	public var trailing: NSLayoutConstraint?
	public var top: NSLayoutConstraint?
	public var bottom: NSLayoutConstraint?

	public var centerX: NSLayoutConstraint?
	public var centerY: NSLayoutConstraint?
	public var height: NSLayoutConstraint?
	public var width :NSLayoutConstraint?

	public var firstBaseline: NSLayoutConstraint?
	public var lastBaseline: NSLayoutConstraint?

	public var others = [NSLayoutConstraint]()
	
	private var shouldBeDelayedActivated = false

	public init(constraints: [NSLayoutConstraint] = [], view: UIView? = nil) {
		super.init()
		self.view = view
		replaceConstraints(constraints)
	}
	
	
	internal typealias Interceptor = (ConstraintsList, UIView) -> Void
	static internal var interceptors = [Interceptor]()
	internal static func intercept(_ callback: @escaping Interceptor, while running: () -> Void) {
		interceptors.append(callback)
		running()
		interceptors.removeLast()
	}

	internal static func grouped(_ running: () -> Void, for view: UIView) -> ConstraintsList {
		var constraints = [NSLayoutConstraint]()
		ConstraintsList.intercept({ list, _ in
			constraints.append(contentsOf: list.all)
		}, while: running)
		return ConstraintsList.activate(constraints, for: view)
	}
	
	/// Activates a list of optional constraints and returns a constraint list
	@discardableResult public static func activate(_ constraints: [NSLayoutConstraint?], for view: UIView) -> ConstraintsList {
		let list = ConstraintsList(constraints: constraints.compactMap({ $0 }), view: view)
		if Self.interceptors.isEmpty == false {
			interceptors.last?(list, view)
		} else {
			list.activate()
		}
		return list
	}
	
	fileprivate static var delayedActivationLists = Set<ConstraintsList>()
	fileprivate static var delayedActivationCount = 0
	fileprivate static var isActivationDelayed: Bool { delayedActivationCount > 0 }
	
	internal static func delayActivation(_ running: () -> Void) {
		delayedActivationCount += 1
		running()
		delayedActivationCount -= 1
		
		guard delayedActivationCount == 0 else { return }
		for list in delayedActivationLists where list.shouldBeDelayedActivated && list.view != nil {
			list.activate()
		}
		delayedActivationLists.removeAll()
	}
	
	// all constraints in the list
	public var all: [NSLayoutConstraint] {
		var items = Array<NSLayoutConstraint>()
		leading.map {items.append($0)}
		trailing.map {items.append($0)}
		top.map {items.append($0)}
		bottom.map {items.append($0)}
		centerX.map {items.append($0)}
		centerY.map {items.append($0)}
		height.map {items.append($0)}
		width.map {items.append($0)}
		firstBaseline.map {items.append($0)}
		lastBaseline.map {items.append($0)}
		items.append(contentsOf: others)
		return items
	}

	// changes the priority of all constraints
	@discardableResult public func changePriority(_ priority: UILayoutPriority) -> ConstraintsList {
		all.forEach {$0.priority = priority}
		return self
	}

	// The insets derived from the top, leading, bottom and trailing insets
	public var insets: NSDirectionalEdgeInsets {
		get {
			var insets = NSDirectionalEdgeInsets.zero
			insets.top = -(top?.constant ?? 0)
			insets.leading = -(leading?.constant ?? 0)
			insets.bottom = bottom?.constant ?? 0
			insets.trailing = trailing?.constant ?? 0
			return insets
		}
		set {
			top?.constant = -newValue.top
			leading?.constant = -newValue.leading
			bottom?.constant = newValue.bottom
			trailing?.constant = newValue.trailing
		}
	}

	// replaces the existing constraints
	public func replaceConstraints(_ constraints: [NSLayoutConstraint]) {
		leading = nil
		trailing = nil
		top = nil
		bottom = nil
		centerX = nil
		centerY = nil
		height = nil
		width = nil
		firstBaseline = nil
		lastBaseline = nil

		func assign(_ value: NSLayoutConstraint, to path: ReferenceWritableKeyPath<ConstraintsList, NSLayoutConstraint?>) {
			if self[keyPath: path] == nil {
				self[keyPath: path] = value
			} else {
				others.append(value)
			}
		}

		for constraint in constraints {
			switch constraint.firstAttribute {
				case .bottom, .bottomMargin: assign(constraint, to: \.bottom)
				case .top, .topMargin: assign(constraint, to: \.top)
				case .leading, .leadingMargin: assign(constraint, to: \.leading)
				case .trailing, .trailingMargin: assign(constraint, to: \.trailing)
				case .centerX, .centerXWithinMargins: assign(constraint, to: \.centerX)
				case .centerY, .centerYWithinMargins: assign(constraint, to: \.centerY)
				case .height: assign(constraint, to: \.height)
				case .width: assign(constraint, to: \.width)
				case .firstBaseline: assign(constraint, to: \.firstBaseline)
				case .lastBaseline: assign(constraint, to: \.lastBaseline)

				case .left, .right, .leftMargin, .rightMargin, .notAnAttribute:
					fallthrough
				@unknown default:
					others.append(constraint)
			}
		}
	}

	// replaces the existing constraints
	public func replace(with block: @autoclosure () -> ConstraintsList) {
		deactivate()
		replaceConstraints(block().all)
	}

	public func replace(by block: () -> ConstraintsList) {
		deactivate()
		replaceConstraints(block().all)
	}

	// activates all constraints
	public func activate() {
		if Self.isActivationDelayed == true {
			shouldBeDelayedActivated = true
			Self.delayedActivationLists.insert(self)
		} else {
			NSLayoutConstraint.activate(all)
		}
	}

	// deactivates all constraints
	public func deactivate() {
		if Self.isActivationDelayed == true {
			shouldBeDelayedActivated = false
		}
		NSLayoutConstraint.deactivate(all)
	}
}
