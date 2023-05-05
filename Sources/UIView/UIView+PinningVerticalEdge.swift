//
//  UIView+PinningVerticalEdge.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 26/04/2021.
//

import UIKit

extension UIView {
	/// Adds a `subview` pinned to the same `edge` in `other`
	///
	/// The `horizontally` parameter by default always applies to the view we
	/// are added to, if you want it to apply to a custom view passed into `other`, use the `attach` or `attached` option:
	///
	/// 	other: .relative(titleLabel), horizontally: attached(.center)
	///
	///	Each option also takes a `LayoutAnchorable`:
	///
	///		other: .relative(titleLabel), horizontally: .filling(.layoutMargins)
	///		other: .relative(titleLabel), horizontally: .centered(in: .safeArea)
	///
	///	And finally, by default we will be constrained to the horizontal edges of the view we are in.
	///	If you want to overflow, use `unconstrained(...)`
	///
	///		other: .superview, horizontally: .unconstrained(.leading)
	///
	///  - Parameters:
	///		- subview: the subview to add and pin
	///		- edge: the edge to pin to in `subview` and `other`
	///		- other: **optional** where to pin to, defaults to `superview`
	///		- horizontally: **optional** how to fill the horizontal space. Defaults to `fill`
	///		- insets: **optional** the insets to apply to `subview`
	///		- spacing: **optional** the spacing to apply between the two edges
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView,
											  pinnedTo edge: VerticalLayoutEdge,
											  of other: YAxisLayout = .default,
											  horizontally: ConstrainedHorizontalLayout = .default,
											  insets: NSDirectionalEdgeInsets = Default.insets,
											  spacing: CGFloat = Default.spacing) -> ConstraintsList {
		return addSubviewForAutoLayout(subview).constrain(edge: edge, to: edge, of: other, horizontally: horizontally, insets: insets, spacing: spacing)
	}

	/// Adds a `subview` pinning `edge` `to` another edge in `other`
	///
	/// The `horizontally` parameter by default always applies to the view we
	/// are added to, if you want it to apply to a custom view passed into `other`, use the `attach` or `attached` option:
	///
	/// 	other: .relative(titleLabel), horizontally: attached(.center)
	///
	///	Each option also takes a `LayoutAnchorable`:
	///
	///		other: .relative(titleLabel), horizontally: .filling(.layoutMargins)
	///		other: .relative(titleLabel), horizontally: .centered(in: .safeArea)
	///
	///	And finally, by default we will be constrained to the horizontal edges of the view we are in.
	///	If you want to overflow, use `unconstrained(...)`
	///
	///		other: .superview, horizontally: .unconstrained(.leading)
	///
	///  - Parameters:
	///		- subview: the subview to add and pin
	///		- edge: the edge to pin to in `subview`
	///		- to: the edge in `other` to pin to
	///		- other: **optional** where to pin to, defaults to `superview`
	///		- horizontally: **optional** how to fill the horizontal space. Defaults to `fill`
	///		- insets: **optional** the insets to apply to `subview`
	///		- spacing: **optional** the spacing to apply between the two edges
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView,
											  pinning edge: VerticalLayoutEdge,
											  to: VerticalLayoutEdge,
											  of other: YAxisLayout = .default,
											  horizontally: ConstrainedHorizontalLayout = .default,
											  insets: NSDirectionalEdgeInsets = Default.insets,
											  spacing: CGFloat = Default.spacing) -> ConstraintsList {
		return addSubviewForAutoLayout(subview).constrain(edge: edge, to: to, of: other, horizontally: horizontally, insets: insets, spacing: spacing)
	}
	
	/// Adds a `subview` by pinning its top edge to `topEdge` and its bottom edge to `bottomEdge`
	///
	///	- Parameters:
	///		- subview: the subview to add and pin
	///		- topEdge: the edge of `top` to pin to `subview`'s top edge
	///		- top: **optional** where to pin the top edge to, defaults to `superview`
	///		- topSpacing: **optional** the spacing to between the `topEdge` and `top`
	///		- bottomEdge: the edge of `bottom` to pin to `subview`'s bottom edge
	///		- bottom: **optional** where to pin the bottom edge to, defaults to `superview`
	///		- bottomSpacing: **optional** the spacing to between the `bottomEdge` and `bottom`
	///		- horizontally: **optional** how to fill the horizontal space. Defaults to `fill`
	///		- insets: **optional** the insets to apply to `subview`
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView,
											  pinningTopTo topEdge: VerticalLayoutEdge,
											  of top: YAxisLayout = .default,
											  spacing topSpacing: CGFloat = Default.spacing,
											  bottomTo bottomEdge: VerticalLayoutEdge,
											  of bottom: YAxisLayout = .default,
											  spacing bottomSpacing: CGFloat = Default.spacing,
											  horizontally: ConstrainedHorizontalLayout = .default,
											  insets: NSDirectionalEdgeInsets = Default.insets) -> ConstraintsList {
		return addSubviewForAutoLayout(subview).constrain(topTo: topEdge, of: top, spacing: topSpacing, bottomTo: bottomEdge, of: bottom, spacing: bottomSpacing, horizontally: horizontally, insets: insets)
	}


	/// Adds a subview by pinning it below another view
	///
	///	- Parameters:
	///		- subview: the subview to add and pin
	///		- otherView: the other view to pin `subview` below
	///		- horizontally: **optional** how to fill the horizontal space. Defaults to `fill`
	///		- insets: **optional** the insets to apply to `subview`
	///		- spacing: **optional** the spacing to apply between the two edges
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView,
											  pinningBelow otherView: UIView,
											  horizontally: ConstrainedHorizontalLayout = .default,
											  insets: NSDirectionalEdgeInsets = Default.insets,
											  spacing: CGFloat = Default.spacing) -> ConstraintsList {
		return addSubview(subview, pinning: .top, to: .bottom, of: .relative(otherView), horizontally: horizontally, insets: insets, spacing: spacing)
	}

	/// Adds a subview by pinning it above another view
	///
	///	- Parameters:
	///		- subview: the subview to add and pin
	///		- otherView: the other view to pin `subview` above
	///		- horizontally: **optional** how to fill the horizontal space. Defaults to `fill`
	///		- insets: **optional** the insets to apply to `subview`
	///		- spacing: **optional** the spacing to apply between the two edges
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView,
											  pinningAbove otherView: UIView,
											  horizontally: ConstrainedHorizontalLayout = .default,
											  insets: NSDirectionalEdgeInsets = Default.insets,
											  spacing: CGFloat = Default.spacing) -> ConstraintsList {
		return addSubview(subview, pinning: .bottom, to: .top, of: .relative(otherView), horizontally: horizontally, insets: insets, spacing: spacing)
	}

	/// Adds a subview by filling the remaining space below another view
	///
	///	- Parameters:
	///		- subview: the subview to add and pin
	///		- otherView: the other view to fill the remaining space below
	///		- bottom: `subview` is filled until here
	///		- horizontally: **optional** how to fill the horizontal space. Defaults to `fill`
	///		- insets: **optional** the insets to apply to `subview`
	///		- spacing: **optional** the spacing to apply between the two edges
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView,
											  fillingRemainingSpaceBelow otherView: UIView,
											  in bottom: YAxisLayout = .default,
											  horizontally: ConstrainedHorizontalLayout = .default,
											  insets: NSDirectionalEdgeInsets = Default.insets,
											  spacing: CGFloat = Default.spacing) -> ConstraintsList {
		// we want horizontally to be targeted to bottom
		return addSubview(subview, pinningTopTo: .bottom, of: .relative(otherView), spacing: spacing, bottomTo: .bottom, of: bottom, spacing: 0, horizontally: horizontally, insets: insets)
	}

	/// Adds a subview by filling the remaining space above another view
	///
	///	- Parameters:
	///		- subview: the subview to add and pin
	///		- otherView: the other view to fill the remaining space above
	///		- top: `subview` is filled until here
	///		- horizontally: **optional** how to fill the horizontal space. Defaults to `fill`
	///		- insets: **optional** the insets to apply to `subview`
	///		- spacing: **optional** the spacing to apply between the two edges
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView,
											  fillingRemainingSpaceAbove otherView: UIView,
											  in top: YAxisLayout = .default,
											  horizontally: ConstrainedHorizontalLayout = .default,
											  insets: NSDirectionalEdgeInsets = Default.insets,
											  spacing: CGFloat = Default.spacing) -> ConstraintsList {
		return addSubview(subview, pinningTopTo: .top, of: top, spacing: 0, bottomTo: .top, of: .relative(otherView), spacing: spacing, horizontally: horizontally, insets: insets)
	}
	
	/// Adds multiple subviews stacked vertically, constrained to each other and the superview edges
	///
	/// - Parameters:
	///		- views: the views to stack horizontally
	///		- in: the vertical boundaries for the outermost views
	///		- horizontally: **optional** how to fill the horizontal space. Defaults to `fill`
	///		- insets: **optional** the insets to apply from superview
	///		- spacing: **optional** the spacing between the views
	public func addSubviewsVertically(_ views: [UIView],
									  in vertically: VerticalAxisLayout = .default,
									  horizontally: ConstrainedHorizontalLayout = .default,
									  insets: NSDirectionalEdgeInsets = Default.insets,
									  spacing: CGFloat = Default.spacing) {
		let actualHorizontally = horizontally.resolve(vertically)
		if views.count == 1 {
			addSubview(views[0], pinningTopTo: .top, of: vertically.top.yAxis, bottomTo: .bottom, of: vertically.bottom.yAxis, horizontally: actualHorizontally, insets: insets)
		} else if views.count == 2 {
			addSubview(views[0], pinnedTo: .top, of: vertically.top.yAxis, horizontally: actualHorizontally, insets: insets)
			addSubview(views[1], fillingRemainingSpaceBelow: views[0], in: vertically.bottom.yAxis, horizontally: actualHorizontally, insets: insets.with(top: spacing), spacing: 0)
		} else if views.count > 0 {
			
			addSubview(views[0], pinnedTo: .top, of: vertically.top.yAxis, horizontally: actualHorizontally, insets: insets)
			for index in 1..<views.count - 1 {
				addSubview(views[index], pinningBelow: views[index-1], horizontally: actualHorizontally, insets: insets.with(vertical: 0), spacing: spacing)
			}
			addSubview(views[views.count - 1], fillingRemainingSpaceBelow: views[views.count - 2], in: vertically.bottom.yAxis, horizontally: actualHorizontally, insets: insets.with(top: spacing), spacing: 0)
		}
	}
	
	/// Adds multiple subviews stacked vertically, constrained to each other and the superview edges
	///
	/// - Parameters:
	///		- views: the views to stack horizontally
	///		- in: the vertical boundaries for the outermost views
	///		- horizontally: **optional** how to fill the horizontal space. Defaults to `fill`
	///		- insets: **optional** the insets to apply from superview
	///		- spacing: **optional** the spacing between the views
	public func addSubviewsVertically(_ views: UIView...,
									  in vertically: VerticalAxisLayout = .default,
									  horizontally: ConstrainedHorizontalLayout = .default,
									  insets: NSDirectionalEdgeInsets = Default.insets,
									  spacing: CGFloat = Default.spacing) {
		addSubviewsVertically(views, in: vertically, horizontally: horizontally, insets: insets, spacing: spacing)
	}

	/// Constrains self` pinning `edge` `to` another edge in `other`
	///
	/// The `horizontally` parameter by default always applies to the view we
	/// are added to, if you want it to apply to a custom view passed into `other`, use the `attach` or `attached` option:
	///
	/// 	other: .relative(titleLabel), horizontally: attached(.center)
	///
	///	Each option also takes a `LayoutAnchorable`:
	///
	///		other: .relative(titleLabel), horizontally: .filling(.layoutMargins)
	///		other: .relative(titleLabel), horizontally: .centered(in: .safeArea)
	///
	///	And finally, by default we will be constrained to the horizontal edges of the view we are in.
	///	If you want to overflow, use `unconstrained(...)`
	///
	///		other: .superview, horizontally: .unconstrained(.leading)
	///
	///  - Parameters:
	///		- edge: the edge to pin to in `self`
	///		- to: the edge in `other` to pin to
	///		- other: **optional** where to pin to, defaults to `superview`
	///		- horizontally: **optional** how to fill the horizontal space. Defaults to `fill`
	///		- insets: **optional** the insets to apply to `subview`
	///		- spacing: **optional** the spacing to apply between the two edges
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func constrain(edge: VerticalLayoutEdge,
											 to: VerticalLayoutEdge,
											 of other: YAxisLayout,
											 horizontally: ConstrainedHorizontalLayout = .default,
											 insets: NSDirectionalEdgeInsets = Default.insets,
											 spacing: CGFloat = Default.spacing) -> ConstraintsList {
		var constraints = constrain(horizontally: horizontally, others: [other], insets: insets, retarget: superview)
		constraints.append(constrain(singleEdge: edge, to: to, of: other, insets: insets, spacing: spacing))
		return ConstraintsList.activate(constraints, for: self)
	}

	/// Constrains `self` by pinning its top edge to `topEdge` and its bottom edge to `bottomEdge`
	///
	///	- Parameters:
	///		- topEdge: the edge of `top` to pin to `self`'s top edge
	///		- top: where to pin the top edge to
	///		- topSpacing: **optional** the spacing to apply between the `topEdge` and `top`
	///		- bottomEdge: the edge of `bottom` to pin to `self`'s bottom edge
	///		- bottom: where to pin the bottom edge to
	///		- bottomSpacing: **optional** the spacing to apply between the `bottomEdge` and `bottom`
	///		- horizontally: **optional** how to fill the horizontal space. Defaults to `fill`
	///		- insets: **optional** the insets to apply to `self`
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func constrain(topTo topEdge: VerticalLayoutEdge,
											 of top: YAxisLayout,
											 spacing topSpacing: CGFloat = Default.spacing,
											 bottomTo bottomEdge: VerticalLayoutEdge,
											 of bottom: YAxisLayout,
											 spacing bottomSpacing: CGFloat = Default.spacing,
											 horizontally: ConstrainedHorizontalLayout = .default,
											 insets: NSDirectionalEdgeInsets = Default.insets) -> ConstraintsList {
		var constraints = constrain(horizontally: horizontally, others: [top, bottom], insets: insets, retarget: superview)
		constraints.append(constrain(singleEdge: .top, to: topEdge, of: top, insets: insets, spacing: topSpacing))
		constraints.append(constrain(singleEdge: .bottom, to: bottomEdge, of: bottom, insets: insets, spacing: bottomSpacing))
		return ConstraintsList.activate(constraints, for: self)
	}

	/// Private helper to constrain a single edge
	private func constrain(singleEdge edge: VerticalLayoutEdge,
							to: VerticalLayoutEdge,
							of other: YAxisLayout,
							insets: NSDirectionalEdgeInsets,
							spacing: CGFloat) -> NSLayoutConstraint? {
		if let selfAnchor = edge.anchor(for: self), let otherProvider = other.y.layoutAnchorsProvider(in: superview), let otherAnchor = to.anchor(for: otherProvider) {
			var constant = edge.effectiveSpacing(for: Default.resolve(spacing))
			constant += edge.effectiveInset(for: Default.resolve(insets))
			return otherAnchor.constraint(equalTo: selfAnchor, constant: constant)
		} else {
			return nil
		}
	}

	/// Private helper to constrain the opposite axis
	internal func constrain(horizontally: ConstrainedHorizontalLayout,
							others: [any SingleAxisLayout],
							insets insetsValue: NSDirectionalEdgeInsets,
							retarget view: UIView?) -> [NSLayoutConstraint?] {
		let insets = Default.resolve(insetsValue)
		var constraints: [NSLayoutConstraint?] = []

		switch horizontally.operation {
			case .none:
				break

			case .default:
				return constrain(horizontally: Default.Resolved.constrainedHorizontalLayout, others: others, insets: insets, retarget: view)

			case .attached(let constrainedLayout):
				// we're attached, so try to only use the other layouts that are not for the superview
				let attachedOthers = others.filter { $0.axis.isForSameView(as: superview) == false }
				let othersToUse = attachedOthers.count > 0 ? attachedOthers : others
				let retargetedView = others.first?.axis.targetedView(in: superview)

				if let constrainedLayout = constrainedLayout {
					return constrain(horizontally: constrainedLayout, others: othersToUse, insets: insets, retarget: retargetedView)
				} else {
					return constrain(horizontally: Default.Resolved.constrainedHorizontalLayoutIgnoringPassthru, others: othersToUse, insets: insets, retarget: retargetedView)
				}

			case .fill(let layout):
				let usableLayout = ConstrainedHorizontalLayout.usableFillLayout(for: layout, others: others, view: view)
				constraints += [
					usableLayout.leading.layoutAnchorsProvider(in: view)?.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -insets.leading),
					usableLayout.trailing.layoutAnchorsProvider(in: view)?.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.trailing),
				]

			case .center(let layout):
				let centerLayout = ConstrainedHorizontalLayout.usableCenterLayout(for: layout?.center, others: others, view: view)
				constraints.append(centerLayout.axis.layoutAnchorsProvider(in: view)?.centerXAnchor.constraint(equalTo: centerXAnchor))

				if horizontally.isConstrained == true {
					let usableLayout = ConstrainedHorizontalLayout.usableFillLayout(for: layout?.fill, others: others, view: view)
					constraints += [
						usableLayout.leading.layoutAnchorsProvider(in: view)?.leadingAnchor.constraint(lessThanOrEqualTo: leadingAnchor, constant: -insets.leading),
						usableLayout.trailing.layoutAnchorsProvider(in: view)?.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: insets.trailing),
					]
				}

			case .start(let layout):
				let usableLayout = ConstrainedHorizontalLayout.usableFillLayout(for: layout, others: others, view: view)
				constraints.append(usableLayout.leading.layoutAnchorsProvider(in: view)?.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -insets.leading))
				if horizontally.isConstrained == true {
					constraints.append(usableLayout.trailing.layoutAnchorsProvider(in: view)?.trailingAnchor.constraint(greaterThanOrEqualTo: trailingAnchor, constant: insets.trailing))
				}

			case .end(let layout):
				let usableLayout = ConstrainedHorizontalLayout.usableFillLayout(for: layout, others: others, view: view)
				constraints.append(usableLayout.trailing.layoutAnchorsProvider(in: view)?.trailingAnchor.constraint(equalTo: trailingAnchor, constant: insets.trailing))
				if horizontally.isConstrained == true {
					constraints.append(usableLayout.leading.layoutAnchorsProvider(in: view)?.leadingAnchor.constraint(lessThanOrEqualTo: leadingAnchor, constant: -insets.leading))
				}
		}
		return constraints
	}
}
