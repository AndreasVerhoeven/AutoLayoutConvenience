//
//  UIView+Centering.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 26/04/2021.
//


import UIKit

extension UIView {
	/// Adds a `subview` by centering it at a `point`
	///
	///  - Parameters:
	///		- subview: the subview to add and center
	///		- other: where to center in, e.g. `superview`
	///		- offset: **optional** how much this view should be offsetted from the center
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult func addSubview(_ subview: UIView, centeredIn other: PointLayout, offset: CGPoint = .zero) -> ConstraintsList {
		return addSubview(subview, pinnedTo: .center, of: other, offset: offset)
	}
}
