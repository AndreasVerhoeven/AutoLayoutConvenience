//
//  UIView+Edges.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 26/05/2021.
//

import UIKit

extension UIView {

	/// Adds a `subview` by aligning its vertical edges to `verticalEdges`. Horizontally
	/// the view will be aligned to `.default`, which usually is filling its superview.
	///
	/// Aligning vertically to : `top` means that the subview will be aligned along its
	/// superview's top edge, will be as high as needed, but does not extend past
	/// the bottom edge (taking `insets` into account). This behavior can be modified
	/// using `.overflow(.top)` which does allow for overflowing past the bottom edge.
	///
	///	- Parameters:
	///		- subview: the subview to add and pin
	///		- verticalEdges: how to align the view vertically
	///		- insets: **optional** the insets to apply to `subview`
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView,
											  aligningVerticallyTo verticalEdges: ConstrainedVerticalLayout,
											  insets: NSDirectionalEdgeInsets = Default.insets) -> ConstraintsList {
		addSubview(subview, aligningVerticallyTo: verticalEdges, horizontallyTo: .default, insets: insets)

	}

	/// Adds a `subview` by aligning its horizontal edges to `horizontalEdges`. Vertically
	/// the view will be aligned to `.default`, which usually is filling its superview.
	///
	/// Aligning horizontally to : `leading` means that the subview will be aligned along its
	/// superview's leading edge, will be as wide as needed, but does not extend past
	/// the trailing edge (taking `insets` into account). This behavior can be modified
	/// using `.overflow(.leading)` which does allow for overflowing past the trailing edge.
	///
	///	- Parameters:
	///		- subview: the subview to add and pin
	///		- horizontalEdges: how to align the view horizontally
	///		- insets: **optional** the insets to apply to `subview`
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView,
											  aligningHorizontallyTo horizontalEdges: ConstrainedHorizontalLayout = .default,
											  insets: NSDirectionalEdgeInsets = Default.insets) -> ConstraintsList {
		addSubview(subview, aligningVerticallyTo: .default, horizontallyTo: horizontalEdges, insets: insets)

	}

	/// Adds a `subview` by aligning its vertical edges to `verticalEdges` and its
	/// horizontal edges to `horizontalEdges`.
	///
	/// Aligning vertically to : `top` means that the subview will be aligned along its
	/// superview's top edge, will be as high as needed, but does not extend past
	/// the bottom edge (taking `insets` into account). This behavior can be modified
	/// using `.overflow(.top)` which does allow for overflowing past the bottom edge.
	///
	/// Aligning horizontally to : `leading` means that the subview will be aligned along its
	/// superview's leading edge, will be as wide as needed, but does not extend past
	/// the trailing edge (taking `insets` into account). This behavior can be modified
	/// using `.overflow(.leading)` which does allow for overflowing past the trailing edge.
	///
	///	- Parameters:
	///		- subview: the subview to add and pin
	///		- verticalEdges: how to align the view vertically
	///		- horizontalEdges: how to align the view horizontally
	///		- insets: **optional** the insets to apply to `subview`
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView,
											  aligningVerticallyTo verticalEdges: ConstrainedVerticalLayout,
											  horizontallyTo horizontalEdges: ConstrainedHorizontalLayout,
											  insets: NSDirectionalEdgeInsets = Default.insets) -> ConstraintsList {
		addSubviewForAutoLayout(subview).constrain(vertically: verticalEdges, horizontally: horizontalEdges, insets: insets)

	}

	/// Constrains a `view` by aligning its vertical edges to `verticalEdges` and its
	/// horizontal edges to `horizontalEdges` to its superview.
	///
	/// Aligning vertically to : `top` means that the subview will be aligned along its
	/// superview's top edge, will be as high as needed, but does not extend past
	/// the bottom edge (taking `insets` into account). This behavior can be modified
	/// using `.overflow(.top)` which does allow for overflowing past the bottom edge.
	///
	/// Aligning horizontally to : `leading` means that the subview will be aligned along its
	/// superview's leading edge, will be as wide as needed, but does not extend past
	/// the trailing edge (taking `insets` into account). This behavior can be modified
	/// using `.overflow(.leading)` which does allow for overflowing past the trailing edge.
	///
	///	- Parameters:
	///		- verticalEdges: how to align the view vertically
	///		- horizontalEdges: how to align the view horizontally
	///		- insets: **optional** the insets to apply to `subview`
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func constrain(vertically: ConstrainedVerticalLayout,
											 horizontally: ConstrainedHorizontalLayout,
											 insets: NSDirectionalEdgeInsets = Default.insets) -> ConstraintsList {
		let verticalConstraints = constrain(horizontally: horizontally, others: [XAxisLayout.default], insets: insets, retarget: superview)
		let horizontalConstraints = constrain(vertically: vertically, others: [YAxisLayout.default], insets: insets, retarget: superview)
		return ConstraintsList.activate(verticalConstraints + horizontalConstraints)
	}

}
