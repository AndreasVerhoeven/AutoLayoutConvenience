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

	/// Adds a `subview` by pinning to an exact `rect` `to` in `other`
	///
	///  - Parameters:
	///		- subview: the subview to add and pin
	///		- rect: the exact rect to pin to
	///		- in: the point in `other` to pin to
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView, pinnedAt rect: CGRect, in other: BoxLayout = .default) -> ConstraintsList {
		return addSubviewForAutoLayout(subview).constrain(pinnedAt: rect, in: other)
	}

	/// Adds a `subview` by pinning to an exact `point` `to` in `other`
	///
	///  - Parameters:
	///		- subview: the subview to add and pin
	///		- point: the exact point to pin to
	///		- in: the point in `other` to pin to
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView, pinnedAt point: CGPoint, in other: BoxLayout = .default) -> ConstraintsList {
		return addSubviewForAutoLayout(subview).constrain(pinnedAt: point, in: other)
	}
	
	/// Adds a `subview` by pinning to an exact `point` `to` in `other`
	///
	///  - Parameters:
	///		- subview: the subview to add and pin
	///		- position: the point to pin, e.g. `topLeading` or `topCenter`
	///		- point: the exact point to pin to
	///		- in: the point in `other` to pin to
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView, pinning position: LayoutPosition, at point: CGPoint, in other: BoxLayout = .default) -> ConstraintsList {
		return addSubviewForAutoLayout(subview).constrain(pinning: position, at: point, in: other)
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

	/// Constrains a `subview` by pinning it to a exact `rect` in `other`
	///  - Parameters:
	///		- subview: the subview to pin
	///		- rect: the exact rect to pin to
	///		- in: the point in `other` to pin to
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func constrain(pinnedAt rect: CGRect, in other: BoxLayout = .default) -> ConstraintsList {
		return ConstraintsList.activate([
			other.leading.layoutAnchorsProvider(in: superview)?.leadingAnchor.anchorWithOffset(to: leadingAnchor).constraint(equalToConstant: rect.minX),
			other.top.layoutAnchorsProvider(in: superview)?.topAnchor.anchorWithOffset(to: topAnchor).constraint(equalToConstant: rect.minY),
			widthAnchor.constraint(equalToConstant: rect.width),
			heightAnchor.constraint(equalToConstant: rect.height),
		])
	}

	/// Constrains a `subview` by pinning it to a exact `point` in `other`
	///  - Parameters:
	///		- subview: the subview to pin
	///		- point: the exact point to pin to
	///		- in: the point in `other` to pin to
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func constrain(pinnedAt point: CGPoint, in other: BoxLayout = .default) -> ConstraintsList {
		return ConstraintsList.activate([
			other.leading.layoutAnchorsProvider(in: superview)?.leadingAnchor.anchorWithOffset(to: leadingAnchor).constraint(equalToConstant: point.x),
			other.top.layoutAnchorsProvider(in: superview)?.topAnchor.anchorWithOffset(to: topAnchor).constraint(equalToConstant: point.y),
		])
	}
	
	/// Constrains a `subview` by pinning it to a exact `point` in `other`
	///  - Parameters:
	///		- subview: the subview to pin
	///		- point: the exact point to pin to
	///		- in: the point in `other` to pin to
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func constrain(pinning position: LayoutPosition, at point: CGPoint, in other: BoxLayout = .default) -> ConstraintsList {
		return ConstraintsList.activate([
			position.xAnchor(for: self)?.anchorWithOffset(to: leadingAnchor).constraint(equalToConstant: point.x),
			position.yAnchor(for: self)?.anchorWithOffset(to: topAnchor).constraint(equalToConstant: point.y),
		])
	}
}
