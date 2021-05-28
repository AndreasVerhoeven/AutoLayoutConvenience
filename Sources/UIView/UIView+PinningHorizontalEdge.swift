//
//  UIView+PinningHorizontalEdge.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 26/04/2021.
//

import UIKit

extension UIView {
	/// Adds a `subview` pinned to the same `edge` in `other`
	///
	/// The `vertically` parameter by default always applies to the view we
	/// are added to, if you want it to apply to a custom view passed into `other`, use the `attach` or `attached` option:
	///
	/// 	other: .relative(titleLabel), horizontally: attached(.center)
	///
	///	Each option also takes a `LayoutAnchorable`:
	///
	///		other: .relative(titleLabel), vertically: .filling(.layoutMargins)
	///		other: .relative(titleLabel), vertically: .centered(in: .safeArea)
	///
	///	And finally, by default we will be constrained to the horizontal edges of the view we are in.
	///	If you want to overflow, use `unconstrained(...)`
	///
	///		other: .superview, vertically: .unconstrained(.leading)
	///
	///  - Parameters:
	///		- subview: the subview to add and pin
	///		- edge: the edge to pin to in `subview` and `other`
	///		- other: **optional** where to pin to, defaults to `superview`
	///		- vertically: **optional** how to fill the vertical space. Defaults to `fill`
	///		- insets: **optional** the insets to apply to `subview`
	///		- spacing: **optional** the spacing to apply between the two edges
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView,
											  pinnedTo edge: HorizontalLayoutEdge,
											  of other: XAxisLayout = .default,
											  vertically: ConstrainedVerticalLayout = .default,
											  insets: NSDirectionalEdgeInsets = Default.insets,
											  spacing: CGFloat = Default.spacing) -> ConstraintsList {
		return addSubviewForAutoLayout(subview).constrain(edge: edge, to: edge, of: other, vertically: vertically, insets: insets, spacing: spacing)
	}

	/// Adds a `subview` pinning `edge` `to` another edge in `other`
	///
	/// The `vertically` parameter by default always applies to the view we
	/// are added to, if you want it to apply to a custom view passed into `other`, use the `attach` or `attached` option:
	///
	/// 	other: .relative(titleLabel), vertically: attached(.center)
	///
	///	Each option also takes a `LayoutAnchorable`:
	///
	///		other: .relative(titleLabel), vertically: .filling(.layoutMargins)
	///		other: .relative(titleLabel), vertically: .centered(in: .safeArea)
	///
	///	And finally, by default we will be constrained to the horizontal edges of the view we are in.
	///	If you want to overflow, use `unconstrained(...)`
	///
	///		other: .superview, vertically: .unconstrained(.leading)
	///
	///  - Parameters:
	///		- subview: the subview to add and pin
	///		- edge: the edge to pin to in `subview`
	///		- to: the edge in `other` to pin to
	///		- other: **optional** where to pin to, defaults to `superview`
	///		- vertically: **optional** how to fill the vertical space. Defaults to `fill`
	///		- insets: **optional** the insets to apply to `subview`
	///		- spacing: **optional** the spacing to apply between the two edges
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView,
											  pinning edge: HorizontalLayoutEdge,
											  to: HorizontalLayoutEdge,
											  of other: XAxisLayout = .default,
											  vertically: ConstrainedVerticalLayout = .default,
											  insets: NSDirectionalEdgeInsets = Default.insets,
											  spacing: CGFloat = Default.spacing) -> ConstraintsList {
		return addSubviewForAutoLayout(subview).constrain(edge: edge, to: to, of: other, vertically: vertically, insets: insets, spacing: spacing)
	}

	/// Adds a `subview` by pinning its leading edge to `leadingEdge` and its trailing edge to `trailingEdge`
	///
	///	- Parameters:
	///		- subview: the subview to add and pin
	///		- leadingEdge: the edge of `top` to pin to `subview`'s top edge
	///		- top: **optional** where to pin the leading edge to, defaults to `superview`
	///		- bottomEdge: the edge of `bottom` to pin to `subview`'s bottom edge
	///		- bottom: **optional** where to pin the bottom edge to, defaults to `superview`
	///		- horizontally: **optional** how to fill the horizontal space. Defaults to `fill`
	///		- insets: **optional** the insets to apply to `subview`
	///		- spacing: **optional** the spacing to apply between the two edges
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView,
											  pinningLeadingTo leadingEdge: HorizontalLayoutEdge,
											  of leading: XAxisLayout = .default,
											  spacing leadingSpacing: CGFloat = Default.spacing,
											  trailingTo trailingEdge: HorizontalLayoutEdge,
											  of trailing: XAxisLayout = .default,
											  spacing trailingSpacing: CGFloat = Default.spacing,
											  vertically: ConstrainedVerticalLayout = .default,
											  insets: NSDirectionalEdgeInsets = Default.insets,
											  spacing: CGFloat = Default.spacing) -> ConstraintsList {
		
		return addSubviewForAutoLayout(subview).constrain(leadingTo: leadingEdge, of: leading, spacing: leadingSpacing, trailingTo: trailingEdge, of: trailing, spacing: trailingSpacing, vertically: vertically, insets: insets)
	}

	/// Adds a subview by pinning it after another view
	///
	///	- Parameters:
	///		- subview: the subview to add and pin
	///		- otherView: the other view to pin `subview` after
	///		- vertically: **optional** how to fill the vertical space. Defaults to `fill`
	///		- insets: **optional** the insets to apply to `subview`
	///		- spacing: **optional** the spacing to apply between the two edges
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView,
											  pinningAfter otherView: UIView,
											  vertically: ConstrainedVerticalLayout = .default,
											  insets: NSDirectionalEdgeInsets = Default.insets,
											  spacing: CGFloat = Default.spacing) -> ConstraintsList {
		return addSubview(subview, pinning: .leading, to: .trailing, of: .relative(otherView), vertically: vertically, insets: insets, spacing: spacing)
	}

	/// Adds a subview by pinning it before another view
	///
	///	- Parameters:
	///		- subview: the subview to add and pin
	///		- otherView: the other view to pin `subview` before
	///		- vertically: **optional** how to fill the vertical space. Defaults to `fill`
	///		- insets: **optional** the insets to apply to `subview`
	///		- spacing: **optional** the spacing to apply between the two edges
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView,
											  pinningBefore otherView: UIView,
											  vertically: ConstrainedVerticalLayout = .default,
											  insets: NSDirectionalEdgeInsets = Default.insets,
											  spacing: CGFloat = Default.spacing) -> ConstraintsList {
		return addSubview(subview, pinning: .trailing, to: .leading, of: .relative(otherView), vertically: vertically, insets: insets, spacing: spacing)
	}

	/// Adds a subview by filling the remaining space after another view
	///
	///	- Parameters:
	///		- subview: the subview to add and pin
	///		- otherView: the other view to fill the remaining space below
	///		- trailing: `subview` is filled until here
	///		- vertically: **optional** how to fill the vertical space. Defaults to `fill`
	///		- insets: **optional** the insets to apply to `subview`
	///		- spacing: **optional** the spacing to apply between the two edges
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView,
											  fillingRemainingSpaceAfter otherView: UIView,
											  in trailing: XAxisLayout = .default,
											  vertically: ConstrainedVerticalLayout = .default,
											  insets: NSDirectionalEdgeInsets = Default.insets,
											  spacing: CGFloat = Default.spacing) -> ConstraintsList {
		return addSubview(subview, pinningLeadingTo: .trailing, of: .relative(otherView), spacing: spacing, trailingTo: .trailing, of: trailing, spacing: 0, vertically: vertically, insets: insets)
	}

	/// Adds a subview by filling the remaining space before another view
	///
	///	- Parameters:
	///		- subview: the subview to add and pin
	///		- otherView: the other view to fill the remaining space above
	///		- leading: `subview` is filled until here
	///		- vertically: **optional** how to fill the horizontal space. Defaults to `fill`
	///		- insets: **optional** the insets to apply to `subview`
	///		- spacing: **optional** the spacing to apply between the two edges
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func addSubview(_ subview: UIView,
											  fillingRemainingSpaceBefore otherView: UIView,
											  in leading: XAxisLayout = .default,
											  vertically: ConstrainedVerticalLayout = .default,
											  insets: NSDirectionalEdgeInsets = Default.insets,
											  spacing: CGFloat = Default.spacing) -> ConstraintsList {
		return addSubview(subview, pinningLeadingTo: .leading, of: leading, spacing: 0, trailingTo: .leading, of: .relative(otherView), spacing: spacing, vertically: vertically, insets: insets)
	}
	
	/// Adds multiple subviews stacked horizontally, constrained to each other and the superview edges
	///
	/// - Parameters:
	///		- views: the views to stack horizontally
	///		- vertically: **optional** how to fill the vertical space. Defaults to `fill`
	///		- insets: **optional** the insets to apply from superview
	///		- spacing: **optional** the spacing between the views
	func addSubviewsHorizontally(_ views: [UIView],
								 vertically: ConstrainedVerticalLayout = .default,
								 insets: NSDirectionalEdgeInsets = Default.insets,
								 spacing: CGFloat = Default.spacing) {
		if views.count == 1 {
			addSubview(views[0], pinningLeadingTo: .leading, trailingTo: .trailing, vertically: vertically, insets: insets)
		} else if views.count == 2 {
			addSubview(views[0], pinnedTo: .leading, vertically: vertically, insets: insets)
			addSubview(views[1], fillingRemainingSpaceAfter: views[0], vertically: vertically, insets: insets.with(leading: spacing), spacing: 0)
		} else if views.count > 0 {
			addSubview(views[0], pinnedTo: .leading, vertically: vertically, insets: insets)
			for index in 1..<views.count - 1 {
				addSubview(views[index], pinningAfter: views[index-1], vertically: vertically, insets: insets.with(horizontal: 0), spacing: spacing)
			}
			addSubview(views[views.count - 1], fillingRemainingSpaceAfter: views[views.count - 2], vertically: vertically, insets: insets.with(leading: spacing), spacing: 0)
		}
	}
	
	/// Adds multiple subviews stacked horizontally, constrained to each other and the superview edges
	///
	/// - Parameters:
	///		- views: the views to stack horizontally
	///		- vertically: **optional** how to fill the vertical space. Defaults to `fill`
	///		- insets: **optional** the insets to apply from superview
	///		- spacing: **optional** the spacing between the views
	func addSubviewsHorizontally(_ views: UIView...,
								 vertically: ConstrainedVerticalLayout = .default,
								 insets: NSDirectionalEdgeInsets = Default.insets,
								 spacing: CGFloat = Default.spacing) {
		addSubviewsHorizontally(views, vertically: vertically, insets: insets, spacing: spacing)
	}

	/// Constrainys self` pinning `edge` `to` another edge in `other`
	///
	/// The `vertically` parameter by default always applies to the view we
	/// are added to, if you want it to apply to a custom view passed into `other`, use the `attach` or `attached` option:
	///
	/// 	other: .relative(titleLabel), vertically: attached(.center)
	///
	///	Each option also takes a `LayoutAnchorable`:
	///
	///		other: .relative(titleLabel), vertically: .filling(.layoutMargins)
	///		other: .relative(titleLabel), vertically: .centered(in: .safeArea)
	///
	///	And finally, by default we will be constrained to the horizontal edges of the view we are in.
	///	If you want to overflow, use `unconstrained(...)`
	///
	///		other: .superview, vertically: .unconstrained(.leading)
	///
	///  - Parameters:
	///		- edge: the edge to pin to in `self`
	///		- to: the edge in `other` to pin to
	///		- other: **optional** where to pin to, defaults to `superview`
	///		- vertically: **optional** how to fill the vertical space. Defaults to `fill`
	///		- insets: **optional** the insets to apply to `subview`
	///		- spacing: **optional** the spacing to apply between the two edges
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func constrain(edge: HorizontalLayoutEdge,
											 to: HorizontalLayoutEdge,
											 of other: XAxisLayout,
											 vertically: ConstrainedVerticalLayout = .default,
											 insets: NSDirectionalEdgeInsets = Default.insets,
											 spacing: CGFloat = Default.spacing) -> ConstraintsList {
		var constraints = constrain(vertically: vertically, others: [other], insets: insets, retarget: superview)
		constraints.append(constrain(singleEdge: edge, to: to, of: other, insets: insets, spacing: spacing))
		return ConstraintsList.activate(constraints)
	}

	/// Constrains `self` by pinning its leading edge to `leadingEdge` and its trailing edge to `trailingEdge`
	///
	///	- Parameters:
	///		- leadingEdge: the edge of `leading` to pin to `self`'s leading edge
	///		- leading: where to pin the top edge to
	///		- leadingSpacing: **optional** the spacing to apply between the `leadingEdge` and `leading`
	///		- trailingEdge: the edge of `trailing` to pin to `self`'s trailing edge
	///		- trailing: where to pin the trailing edge to
	///		- trailingSpacing: **optional** the spacing to apply between the `trailingEdge` and `trailing`
	///		- vertically: **optional** how to fill the vertical space. Defaults to `fill`
	///		- insets: **optional** the insets to apply to `self`
	///		- spacing: **optional** the spacing to apply between the two edges
	///
	/// - Returns: A `ConstraintsList` with the created constraints
	@discardableResult public func constrain(leadingTo leadingEdge: HorizontalLayoutEdge,
											 of leading: XAxisLayout,
											 spacing leadingSpacing: CGFloat = Default.spacing,
											 trailingTo trailingEdge: HorizontalLayoutEdge,
											 of trailing: XAxisLayout,
											 spacing trailingSpacing: CGFloat = Default.spacing,
											 vertically: ConstrainedVerticalLayout = .default,
											 insets: NSDirectionalEdgeInsets = Default.insets,
											 spacing: CGFloat = Default.spacing) -> ConstraintsList {
		var constraints = constrain(vertically: vertically, others: [leading, trailing], insets: insets, retarget: superview)
		constraints.append(constrain(singleEdge: .leading, to: leadingEdge, of: leading, insets: insets, spacing: leadingSpacing))
		constraints.append(constrain(singleEdge: .trailing, to: trailingEdge, of: trailing, insets: insets, spacing: trailingSpacing))
		return ConstraintsList.activate(constraints)
	}

	/// Private helper to constrain a single edge
	private func constrain(singleEdge edge: HorizontalLayoutEdge,
							to: HorizontalLayoutEdge,
							of other: XAxisLayout,
							insets: NSDirectionalEdgeInsets,
							spacing: CGFloat) -> NSLayoutConstraint? {
		if let selfAnchor = edge.anchor(for: self), let otherProvider = other.x.layoutAnchorsProvider(in: superview), let otherAnchor = to.anchor(for: otherProvider) {
			var constant = edge.effectiveSpacing(for: Default.resolve(spacing))
			constant -= edge.effectiveInset(for: Default.resolve(insets))
			return otherAnchor.constraint(equalTo: selfAnchor, constant: constant)
		} else {
			return nil
		}
	}

	internal func constrain(vertically: ConstrainedVerticalLayout,
								others: [SingleAxisLayout],
								insets insetsValue: NSDirectionalEdgeInsets,
								retarget view: UIView?) -> [NSLayoutConstraint?] {
		let insets = Default.resolve(insetsValue)
		var constraints: [NSLayoutConstraint?] = []
		switch vertically.operation {
			case .none:
				break

			case .default:
				return constrain(vertically: Default.Resolved.constrainedVerticalLayout, others: others, insets: insets, retarget: view)

			case .attached(let constrainedLayout):
				// we're attached, so try to only use the other layouts that are not for the superview
				let attachedOthers = others.filter { $0.axis.isForSameView(as: superview) == false }
				let othersToUse = attachedOthers.count > 0 ? attachedOthers : others
				let retargetedView = others.first?.axis.targetedView(in: superview)

				if let constrainedLayout = constrainedLayout {
					return constrain(vertically: constrainedLayout, others: othersToUse, insets: insets, retarget: retargetedView)
				} else {
					return constrain(vertically: Default.Resolved.constrainedVerticalLayoutIgnoringPassthru, others: othersToUse, insets: insets, retarget: retargetedView)
				}

			case .fill(let layout):
				let usableLayout = ConstrainedVerticalLayout.usableFillLayout(for: layout, others: others, view: view)
				constraints += [
					usableLayout.top.layoutAnchorsProvider(in: view)?.topAnchor.constraint(equalTo: topAnchor, constant: -insets.top),
					usableLayout.bottom.layoutAnchorsProvider(in: view)?.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom),
				]

			case .center(let layout):
				let centerLayout = ConstrainedVerticalLayout.usableCenterLayout(for: layout?.center, others: others, view: view)
				constraints.append(centerLayout.axis.layoutAnchorsProvider(in: view)?.centerYAnchor.constraint(equalTo: centerYAnchor))

				if vertically.isConstrained == true {
					let usableLayout = ConstrainedVerticalLayout.usableFillLayout(for: layout?.fill, others: others, view: view)
					constraints += [
						usableLayout.top.layoutAnchorsProvider(in: view)?.topAnchor.constraint(lessThanOrEqualTo: topAnchor, constant: -insets.top),
						usableLayout.bottom.layoutAnchorsProvider(in: view)?.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: insets.bottom),
					]
				}

			case .start(let layout):
				let usableLayout = ConstrainedVerticalLayout.usableFillLayout(for: layout, others: others, view: view)
				constraints.append(usableLayout.top.layoutAnchorsProvider(in: view)?.topAnchor.constraint(equalTo: topAnchor, constant: -insets.top))
				if vertically.isConstrained == true {
					constraints.append(usableLayout.bottom.layoutAnchorsProvider(in: view)?.bottomAnchor.constraint(greaterThanOrEqualTo: bottomAnchor, constant: insets.bottom))
				}

			case .end(let layout):
				let usableLayout = ConstrainedVerticalLayout.usableFillLayout(for: layout, others: others, view: view)
				constraints.append(usableLayout.bottom.layoutAnchorsProvider(in: view)?.bottomAnchor.constraint(equalTo: bottomAnchor, constant: insets.bottom))
				if vertically.isConstrained == true {
					constraints.append(usableLayout.top.layoutAnchorsProvider(in: view)?.topAnchor.constraint(lessThanOrEqualTo: topAnchor, constant: -insets.top))
				}
		}
		return constraints
	}
}
