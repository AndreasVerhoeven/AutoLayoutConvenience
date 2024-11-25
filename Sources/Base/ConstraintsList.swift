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
final public class ConstraintsList: NSObject {
	/// the view the constraints should be valid for
	public private(set) weak var view: UIView?

	/// all the constraints
	public private(set) var all = [NSLayoutConstraint]()

	/// the identifier of this list
	public var identifier: Identifier?

	// MARK: - Specific constraints
	public var allLeading: [NSLayoutConstraint] { allMatching(.leading, or: .leadingMargin) }
	public var allTrailing: [NSLayoutConstraint] { allMatching(.trailing, or: .trailingMargin) }

	public var allTop: [NSLayoutConstraint] { allMatching(.top, or: .topMargin) }
	public var allBottom: [NSLayoutConstraint] { allMatching(.bottom, or: .bottomMargin) }

	public var allCenterX: [NSLayoutConstraint] { allMatching(.centerX, or: .centerXWithinMargins) }
	public var allCenterY: [NSLayoutConstraint] { allMatching(.centerY, or: .centerYWithinMargins) }

	public var allHeight: [NSLayoutConstraint] { all.filter { $0.firstAttribute == .height } }
	public var allWidth: [NSLayoutConstraint] { all.filter { $0.firstAttribute == .width } }

	public var allFirstBaseline: [NSLayoutConstraint] { all.filter { $0.firstAttribute == .firstBaseline } }
	public var allLastBaseline: [NSLayoutConstraint] { all.filter { $0.firstAttribute == .lastBaseline } }

	public var others: [NSLayoutConstraint] {
		return all.filter { constraint in
			switch constraint.firstAttribute {
				case .bottom, .bottomMargin: return false
				case .top, .topMargin: return false
				case .leading, .leadingMargin: return false
				case .trailing, .trailingMargin: return false
				case .centerX, .centerXWithinMargins: return false
				case .centerY, .centerYWithinMargins: return false
				case .height: return false
				case .width: return false
				case .firstBaseline: return false
				case .lastBaseline: return false

				case .left, .right, .leftMargin, .rightMargin, .notAnAttribute:
					fallthrough
				@unknown default:
					return true
			}
		}
	}

	// MARK: - Convenience accessors, returning the first such given constraint
	public var leading: NSLayoutConstraint? { allLeading.first }
	public var trailing: NSLayoutConstraint? { allTrailing.first }
	public var top: NSLayoutConstraint? { allTop.first }
	public var bottom: NSLayoutConstraint? { allBottom.first }

	public var centerX: NSLayoutConstraint? {allCenterX.first }
	public var centerY: NSLayoutConstraint? { allCenterY.first }
	public var height: NSLayoutConstraint? { allHeight.first }
	public var width :NSLayoutConstraint? {allWidth.first }

	public var firstBaseline: NSLayoutConstraint? { allFirstBaseline.first }
	public var lastBaseline: NSLayoutConstraint? { allLastBaseline.first }

	/// creates a constraints list
	public init(constraints: [NSLayoutConstraint] = [], view: UIView? = nil, identifier: Identifier? = nil) {
		super.init()
		self.view = view
		self.identifier = identifier
		replaceConstraints(constraints)
	}

	/// groups all constraints created in this block in a single list
	public static func grouped(_ running: () -> Void, for view: UIView) -> ConstraintsList {
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
	
	/// changes the priority of all constraints
	@discardableResult public func changePriority(_ priority: UILayoutPriority) -> ConstraintsList {
		all.forEach {$0.priority = priority}
		return self
	}

	/// The insets derived from the top, leading, bottom and trailing insets.
	/// If there are multiple top/leading/bottom/trailing constraints, the first one will be used for the getter,
	/// but setting them changes them all
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
			allTop.forEach { $0.constant = -newValue.top }
			allLeading.forEach { $0.constant = -newValue.leading }
			allBottom.forEach { $0.constant = newValue.bottom }
			allTrailing.forEach { $0.constant = newValue.trailing }
		}
	}

	/// replaces the existing constraints
	public func replaceConstraints(_ constraints: [NSLayoutConstraint]) {
		all = constraints
	}

	/// replaces the existing constraints
	public func replace(with block: @autoclosure () -> ConstraintsList) {
		deactivate()
		replaceConstraints(block().all)
	}

	/// replaces the existing constraints
	public func replace(by block: () -> ConstraintsList) {
		deactivate()
		replaceConstraints(block().all)
	}

	/// activates all constraints
	public func activate() {
		if Self.isActivationDelayed == true {
			shouldBeDelayedActivated = true
			Self.delayedActivationLists.insert(self)
		} else {
			NSLayoutConstraint.activate(all)
		}
	}

	/// deactivates all constraints
	public func deactivate() {
		if Self.isActivationDelayed == true {
			shouldBeDelayedActivated = false
		}
		NSLayoutConstraint.deactivate(all)
	}

	// MARK: - Internal
	// MARK: Delayed Activation

	/// delayed activation does what it says: it delays activating the constraints in all lists
	/// until a later point - this can be useful when constrains depend upon multiple views:
	/// they first need to be all added to the hierarchy before they can be activated - this helps with that
	fileprivate static var delayedActivationLists = Set<ConstraintsList>()
	fileprivate static var delayedActivationCount = 0
	fileprivate static var isActivationDelayed: Bool { delayedActivationCount > 0 }

	/// if true, activation of the constraints in this list should be delayed until a later point in time
	private var shouldBeDelayedActivated = false

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

	// MARK: Intercepting
	internal typealias Interceptor = (ConstraintsList, UIView) -> Void
	static internal var interceptors = [Interceptor]()

	/// Intercepts all created constraint lists and hand them over to a callback
	internal static func intercept(_ callback: @escaping Interceptor, while running: () -> Void) {
		interceptors.append(callback)
		running()
		interceptors.removeLast()
	}

	// MARK: - Privates
	private func allMatching(_ a: NSLayoutConstraint.Attribute, or  b: NSLayoutConstraint.Attribute) -> [NSLayoutConstraint] {
		return all.filter { $0.firstAttribute == a || $0.secondAttribute == b }
	}
}

extension ConstraintsList {
	/// Representing an identified constraint list
	public struct Identifier: RawRepresentable, Hashable {
		public var rawValue: String

		public init(rawValue: String) {
			self.rawValue = rawValue
		}

		public static func custom(_ value: String) -> Self {
			return Self(rawValue: value)
		}

		public static let main = Self(rawValue: "main")
		public static let width = Self(rawValue: "width")
		public static let height = Self(rawValue: "height")
		public static let size = Self(rawValue: "size")
		public static let box = Self(rawValue: "box")
	}
}

