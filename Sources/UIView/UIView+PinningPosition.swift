//
//  UIView+PinningPosition.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 26/04/2021.
//

import UIKit

extension UIView {
	/// Adds a `subview` pinned to the same position in `other`
	///
	///  - Parameters:
	///		- subview: the subview to add and pin
	///		- position: the point to pin, e.g. `topLeading` or `topCenter`
	///		- other: **optional** where to pin to, defaults to `superview`,
	///		- offset: **optional** how much this view should be offsetted from the center
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView, pinnedTo position: LayoutPosition, of other: PointLayout = .default, offset: CGPoint = .zero) -> ConstraintsList {
		return addSubview(subview, pinning: position, to: position, of: other, offset: offset)
	}

	/// Adds a `subview` by pinning a `position` in `self` `to` another position in `other`
	///
	///  - Parameters:
	///		- subview: the subview to add and pin
	///		- position: the point to pin, e.g. `topLeading` or `topCenter`
	///		- to: the point in `other` to pin to
	///		- other: **optional** where to pin to, defaults to `superview`,
	///		- offset: **optional** how much this view should be offsetted from the center
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView, pinning position: LayoutPosition, to: LayoutPosition, of other: PointLayout = .default, offset: CGPoint = .zero) -> ConstraintsList {
		return addSubviewForAutoLayout(subview).constrain(pinning: position, to: to, of: other, offset: offset)
	}

	/// Constraints a `subview` by pinning a `position` in `self` `to` another position in `other`
	///
	///  - Parameters:
	///		- subview: the subview to add and pin
	///		- position: the point to pin, e.g. `topLeading` or `topCenter`
	///		- to: the point in `other` to pin to
	///		- other: **optional** where to pin to, defaults to `superview`,
	///		- offset: **optional** how much this view should be offsetted from the center
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func constrain(pinning position: LayoutPosition, to: LayoutPosition, of other: PointLayout = .default, offset: CGPoint = .zero) -> ConstraintsList {
		return ConstraintsList.activate([
			to.xAnchor(for: other.x.layoutAnchorsProvider(in: superview)).flatMap({ position.xAnchor(for: self)?.constraint(equalTo: $0, constant: offset.x) }),
			to.yAnchor(for: other.y.layoutAnchorsProvider(in: superview)).flatMap({ position.yAnchor(for: self)?.constraint(equalTo: $0, constant: offset.x) }),
		])
	}
}
