//
//  UIView+Filling.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 26/04/2021.
//

import UIKit

extension UIView {
	/// Adds a `subview` filling a `box`, for example:
	///
	/// - Parameters:
	/// 	- subview: the subview to add and fill
	/// 	- box: the box to fill. A box defines the 4 edges to which `subview` will be pinned
	/// 	- insets: **optional** the insets to apply to `subview` with respect to `box`
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView, filling box: BoxLayout, insets: NSDirectionalEdgeInsets = Default.insets) -> ConstraintsList {
		return addSubviewForAutoLayout(subview).constrain(filling: box, insets: insets)
	}


	/// Constraints `self` by filling a `box`
	///
	/// - Parameters:
	/// 	- box: the box to fill. A box defines the 4 edges to which `self` will be pinned
	/// 	- insets: **optional** the insets to apply to `self` with respect to `box`
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func constrain(filling box: BoxLayout, insets: NSDirectionalEdgeInsets = Default.insets) -> ConstraintsList {
		let resolvedInsets = Default.resolve(insets)
		return ConstraintsList.activate([
			box.top.layoutAnchorsProvider(in: superview)?.topAnchor.constraint(equalTo: topAnchor, constant: -resolvedInsets.top),
			box.leading.layoutAnchorsProvider(in: superview)?.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -resolvedInsets.leading),
			box.bottom.layoutAnchorsProvider(in: superview)?.bottomAnchor.constraint(equalTo: bottomAnchor, constant: resolvedInsets.bottom),
			box.trailing.layoutAnchorsProvider(in: superview)?.trailingAnchor.constraint(equalTo: trailingAnchor, constant: resolvedInsets.trailing),
		], for: self)
	}
}
