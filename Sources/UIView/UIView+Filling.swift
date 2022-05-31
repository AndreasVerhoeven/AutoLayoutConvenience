//
//  UIView+Filling.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 26/04/2021.
//

import UIKit

extension UIView {
	/// Adds a `subview` filling a `box`, for example: `addSubview(subview, filling: .safeArea)`
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
	
	
	/// Adds a `subview` at a position while not being bigger than  a given `box`, for example: `addSubview(subview, fillingAtMost: safeArea, pinning: .center, to: .topLeading)`
	///
	/// - Parameters:
	/// 	- subview: the subview to add
	/// 	- box: the box to fill at most. A box defines the 4 edges `subview` will not extend beyond
	/// 	- insets: **optional** the insets to apply to rectangle defined by `box`.
	///		- position: the point to pin, e.g. `topLeading` or `topCenter`
	///		- to: the point in `other` to pin to
	///		- other: **optional** where to pin to, defaults to `superview`,
	///		- offset: **optional** how much this view should be offsetted from the center
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(
		_ subview: UIView,
		fillingAtMost box: BoxLayout,
		insets: NSDirectionalEdgeInsets = Default.insets,
		pinning position: LayoutPosition,
		to: LayoutPosition,
		of other: PointLayout = .default,
		offset: CGPoint = .zero) -> ConstraintsList {
			return addSubviewForAutoLayout(subview).constrain(fillingAtMost: box, insets: insets, pinning: position, to: to, of: other, offset: offset)
		}
	
	/// Adds a `subview` at a position while not being bigger than  a given `box`, for example: `addSubview(subview, fillingAtMost: safeArea, pinningTo: .center)`
	///
	/// - Parameters:
	/// 	- subview: the subview to add
	/// 	- box: the box to fill at most. A box defines the 4 edges `subview` will not extend beyond
	/// 	- insets: **optional** the insets to apply to rectangle defined by `box`.
	///		- position: the point to pin, e.g. `topLeading` or `topCenter`
	///		- other: **optional** where to pin to, defaults to `superview`,
	///		- offset: **optional** how much this view should be offsetted from the center
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(
		_ subview: UIView,
		fillingAtMost box: BoxLayout,
		insets: NSDirectionalEdgeInsets = Default.insets,
		pinnedTo position: LayoutPosition = .center,
		of other: PointLayout = .default,
		offset: CGPoint = .zero) -> ConstraintsList {
			return addSubview(subview, fillingAtMost: box, insets: insets, pinning: position, to: position, of: other, offset: offset)
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
	
	/// Constraints a `self` at a position while not being bigger than  a given `box`.
	///
	/// - Parameters:
	/// 	- box: the box to fill at most. A box defines the 4 edges `subview` will not extend beyond
	/// 	- insets: **optional** the insets to apply to rectangle defined by `box`.
	///		- position: the point to pin, e.g. `topLeading` or `topCenter`
	///		- to: the point in `other` to pin to
	///		- other: **optional** where to pin to, defaults to `superview`,
	///		- offset: **optional** how much this view should be offsetted from the center
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func constrain(
		fillingAtMost box: BoxLayout,
		insets: NSDirectionalEdgeInsets = Default.insets,
		pinning position: LayoutPosition,
		to: LayoutPosition,
		of other: PointLayout = .default,
		offset: CGPoint = .zero) -> ConstraintsList {
			let resolvedInsets = Default.resolve(insets)
			return ConstraintsList.grouped({
				constrain(pinning: position, to: to, of: other, offset: offset).changePriority(.defaultHigh.lower)
				constrain(filling: box, insets: insets).changePriority(.defaultLow)
				ConstraintsList.activate([
					box.top.layoutAnchorsProvider(in: superview)?.topAnchor.constraint(lessThanOrEqualTo: topAnchor, constant: -resolvedInsets.top),
					box.leading.layoutAnchorsProvider(in: superview)?.leadingAnchor.constraint(lessThanOrEqualTo: leadingAnchor, constant: -resolvedInsets.leading),
					box.bottom.layoutAnchorsProvider(in: superview)?.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: resolvedInsets.bottom),
					box.trailing.layoutAnchorsProvider(in: superview)?.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: resolvedInsets.trailing),
				], for: self).changePriority(.required)
			}, for: self)
		}
}
