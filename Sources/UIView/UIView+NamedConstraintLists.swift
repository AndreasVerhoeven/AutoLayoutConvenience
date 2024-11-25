//
//  UIView+NamedConstraintLists.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 25/11/2024.
//

import UIKit

extension UIView {
	/// Adds all constraints created in the closure and stored them with an identifier.
	/// This is an alias for `replaceStoredConstraints()`
	///
	/// Stored Constraints are a convenience mechanism where the constraints created in the
	/// closure are automatically stored for you under an identifier you give.
	/// If you want to modify the constraints later, you can call `replaceStoredConstraints()` with the
	/// same identifier and replace all the constraints with new ones.
	///
	/// The convenience is that you don't have to keep track of the created constraints yourself, this is all
	/// done for you.
	@discardableResult public func addStoredConstraints(for identifier: ConstraintsList.Identifier = .main, run: () -> Void) -> ConstraintsList {
		replaceStoredConstraints(for: identifier, run: run)
	}

	/// Replaces earlier created stored constraints with this identifier with the new constraints
	/// created in the closure.
	/// If there were no stored constraints with this identifier yet, the new constraints will
	/// just be added. Thus, you can always call `replaceStoredConstraints` or `addStoredConstraints`
	/// to set up or update the constraints.
	///
	/// Stored Constraints are a convenience mechanism where the constraints created in the
	/// closure are automatically stored for you under an identifier you give.
	/// If you want to modify the constraints later, you can call `replaceStoredConstraints()` with the
	/// same identifier and replace all the constraints with new ones.
	///
	/// The convenience is that you don't have to keep track of the created constraints yourself, this is all
	/// done for you.
	@discardableResult public func replaceStoredConstraints(for identifier: ConstraintsList.Identifier = .main, run: () -> Void) -> ConstraintsList {
		storedConstraintsList(for: identifier)?.deactivate()
		let list = ConstraintsList.grouped(run, for: self)
		list.identifier = identifier
		namedConstraintsList.items[identifier] = list

		if UIView.inheritedAnimationDuration > 0 {
			superview?.setNeedsLayout()
			superview?.layoutIfNeeded()
		}

		return list
	}

	/// Returns the stored constrainst list for the given identifier
	public func storedConstraintsList(for identifier: ConstraintsList.Identifier = .main) -> ConstraintsList? {
		return namedConstraintsList.items[identifier]
	}

	/// Activates or deactivates the sotred constraints list for the given identifier
	public func setStoredConstraints(for identifier: ConstraintsList.Identifier = .main, isActive: Bool) {
		storedConstraintsList(for: identifier)?.isActive = isActive
	}

	fileprivate static var namedCollectionListKey = 0
	fileprivate var namedConstraintsList: NamedConstraintsListCollection {
		if let collection = objc_getAssociatedObject(self, &Self.namedCollectionListKey) as? NamedConstraintsListCollection {
			return collection
		}

		let collection = NamedConstraintsListCollection()
		objc_setAssociatedObject(self, &Self.namedCollectionListKey, collection, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
		return collection
	}

	fileprivate final class NamedConstraintsListCollection {
		var items = [ConstraintsList.Identifier: ConstraintsList]()
	}
}
