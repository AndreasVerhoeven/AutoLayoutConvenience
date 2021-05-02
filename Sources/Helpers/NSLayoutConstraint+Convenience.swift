//
//  NSLayoutConstraint+Convenience.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 23/04/2021.
//

import UIKit

extension NSLayoutConstraint {
	/// Changes the priority of the constraint
	///
	/// - Parameters:
	///		- priority: the priority to set to this constraint
	///
	///	- Returns: `self`, useful for chaining
	@discardableResult public func with(priority: UILayoutPriority) -> NSLayoutConstraint {
		self.priority = priority
		return self
	}

	/// Sets the layout priority of this constraint
	/// to `stackViewWorkaroundHigh`
	///
	/// - Returns: `self` useful for chaining
	public var stackViewWorkaroundHigh: NSLayoutConstraint {
		return with(priority: .stackViewWorkaroundHigh)
	}

	/// Sets the layout priority of this constraint
	/// to `selfSizingCellHeightWorkaround`
	///
	/// - Returns: `self` useful for chaining
	public var selfSizingCellHeightWorkaround: NSLayoutConstraint {
		return with(priority: .selfSizingCellHeightWorkaround)
	}
}

