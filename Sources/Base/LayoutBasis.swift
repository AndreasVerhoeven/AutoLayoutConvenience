//
//  LayoutBasis.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 25/04/2021.
//

import UIKit

/// Layout is defined in 3 layers:
///		- `LayoutAnchorsProvider`, abstracting over `UIView` & `UILayoutGuide`,
///								   providing access the layoutAnchors
///
/// 	- `LayoutAnchorable`, abstracting over all the layout guides and views,
/// 						  providing options such as `.safeArea`, `.relative()`, `.default`.
/// 						  A `LayoutAnchorable` provides a `LayoutAnchorsProvider` when giving a view.
///
///		- `*Layout`, various groups of **typed** anchorables, e.g. `BoxLayout`, `HorizontalAxisLayout`, `PointLayout`
///					 each of these layouts have convenience factory methods, such as `.superview`, `.safeArea`.
///
///
/// The general flow works as follows:
///		`Layout` -> `LayoutAnchorable` -> `LayoutAnchorsProvider` + `view` -> `NSLayoutAnchor` -> `NSConstraint` -> `ConstraintsList`
///
///	Example for `addSubview(filling:)`:
///		1. A filling operation constraints all 4 edges, so it takes a `BoxLayout`
///		2. A `BoxLayout` has anchorables for all 4 edges: `top`, `leading`, `bottom`, `trailing`
///		3. For each edge, the helper method gets a `LayoutAnchorsProvider` from the appropriate edge in the `BoxLayout`
///		4. The helper method constraints the right `NSLayoutAnchors` from the `LayoutAnchorsProvider`
///		5. That creates `NSLayoutConstraints`, which are collected and returned in `ConstraintsList`
///

/// Abstraction protocol for things that provide NSLayoutAnchors:
/// usually either a `UIView` or a `UILayoutGuide`
public protocol LayoutAnchorsProvider {
	var leadingAnchor: NSLayoutXAxisAnchor { get }
	var trailingAnchor: NSLayoutXAxisAnchor { get }
	var leftAnchor: NSLayoutXAxisAnchor { get }
	var rightAnchor: NSLayoutXAxisAnchor { get }
	var topAnchor: NSLayoutYAxisAnchor { get }
	var bottomAnchor: NSLayoutYAxisAnchor { get }
	var widthAnchor: NSLayoutDimension { get }
	var heightAnchor: NSLayoutDimension { get }
	var centerXAnchor: NSLayoutXAxisAnchor { get }
	var centerYAnchor: NSLayoutYAxisAnchor { get }
}

/// Abstraction protocol for things that provide
/// baseline layout anchors
public protocol BaselineLayoutAnchorsProvider {
	var firstBaselineAnchor: NSLayoutYAxisAnchor { get }
	var lastBaselineAnchor: NSLayoutYAxisAnchor { get }
}

// UIView and UILayoutGuide conform automatically
extension UIView: LayoutAnchorsProvider, BaselineLayoutAnchorsProvider {}
extension UILayoutGuide: LayoutAnchorsProvider {}


// MARK: -

/// A `LayoutAnchorable` defines to what a layout
/// operation is anchored and can be asked for an appropriate
/// `LayoutAnchorsProvider`
public enum LayoutAnchorable {
	/// Not anchored to anything, essentially a no-op
	case none

	/// Anchored to the `default` anchorable, usually `superview`
	case `default`

	/// Anchored to the `superview` of the relevant view
	case superview

	/// Anchored to a specified other view that is a relative
	/// (they share the same superview somewhere in the hierarchy)
	/// than the relevant view
	case relative(UIView)

	/// Anchored to a specific `UILayoutGuide`
	case guide(UILayoutGuide)

	/// Anchored to the `safeAreaLayoutGuide` of the relevant view
	case safeArea

	/// Anchored to the `safeAreaLayoutGuide` of a specific view
	case safeAreaOf(UIView)

	/// Anchored to the `layoutMarginsGuide` of the relevant view
	case layoutMargins

	/// Anchored to the `layoutMarginsGuide` of a specific view
	case layoutMarginsOf(UIView)

	/// Anchored to the `readableContentLayoutGuide` of the relevant view
	case readableContent

	/// Anchored to the `readableContentLayoutGuide` of the specific view
	case readableContentOf(UIView)

	/// Anchored to the `contentLayoutGuide` of the relevant view if
	/// that view is a `UIScrollView`, otherwise anchored to the relevant view
	case scrollContent

	/// Anchored to the `contentLayoutGuide` of the specified `UIScrollView`
	case scrollContentOf(UIScrollView)

	/// Anchored to the `frameLayoutGuide` of the relevant view if
	/// that view is a `UIScrollView`, otherwise anchored to the relevant view
	case scrollFrame

	/// Anchored to the `frameLayoutGuide` of the specified `UIScrollView`
	case scrollFrameOf(UIScrollView)
}

// MARK: - Layouts

/// This defines the layout anchors for a box layout where
/// all 4 edges are needed, such as a **filling** operation
public struct BoxLayout {
	public var top: LayoutAnchorable
	public var leading: LayoutAnchorable
	public var bottom: LayoutAnchorable
	public var trailing: LayoutAnchorable
}

/// This defines the layout anchors for horizontal layout
/// where we need the limiting edges in the horizontal axis
public struct HorizontalAxisLayout {
	public var leading: LayoutAnchorable
	public var trailing: LayoutAnchorable
}

/// This defines the layout anchors for vertical layout
/// where we need the limiting edges in the vertical axis
public struct VerticalAxisLayout {
	public var top: LayoutAnchorable
	public var bottom: LayoutAnchorable
}

/// This defines the layout anchors for a specific point
/// where we need to know the location in both axis
public struct PointLayout {
	public var x: LayoutAnchorable
	public var y: LayoutAnchorable
}

/// This defines the layout for a specific point
/// on the x axis
public struct XAxisLayout {
	public var x: LayoutAnchorable
}

/// This defines the layout for a specific point
/// on the y axis
public struct YAxisLayout {
	public var y: LayoutAnchorable
}

/// This defines how a layout is constrained
public struct ConstrainedLayout<FillLayout: BaseLayout, MainAxisLayout: SingleAxisLayout> {
	public struct CenteredLayout {
		public var center: MainAxisLayout
		public var fill: FillLayout
	}

	public typealias FillLayout = FillLayout
	public typealias MainAxisLayout = MainAxisLayout

	public enum Operation {
		case none
		case `default`
		indirect case attached(ConstrainedLayout?)
		case fill(FillLayout?)
		case center(CenteredLayout?)
		case start(FillLayout?)
		case end(FillLayout?)
	}
	public var operation: Operation
	public var isConstrained: Bool = true
}

public typealias ConstrainedHorizontalLayout = ConstrainedLayout<HorizontalAxisLayout, XAxisLayout>
public typealias ConstrainedVerticalLayout = ConstrainedLayout<VerticalAxisLayout, YAxisLayout>

// MARK: - Edges

/// The horizontal edges a view can be positioned along
///
///
/// For example, we can pin a view along the leading axis
/// of its superview if its width is defined or it has an
/// intrinsic content size
///
///		addSubview(subview, pinnedTo: .leading, spacing: 4)
public enum HorizontalLayoutEdge {
	case leading
	case centerX
	case trailing
}

/// The vertical edges a view can be positioned along
///
/// For example, we can pin a views top the the bottom
/// of another view if this views height is defined or if it
/// has an intrinsic contentSize:
///
///		subview.constrain(height: 22)
///		addSubview(subview, pinning: .top, to: .bottom, of: siblingView)
public enum VerticalLayoutEdge {
	case top
	case centerY
	case bottom
}

// MARK: - Positions

/// The positions a view can be pinned to
///
/// All values describe a position on both x- and y-axis.
///
/// For example, we can pin a view to the topLeading point of
/// its superviews safeArea with if its height and width are
/// defined or if the view has an intrinsic size:
///
/// 	addSubview(subview, pinnedTo: topLeading, in: .safeArea)
public enum LayoutPosition: Int {
	case topLeading
	case topCenter
	case topTrailing

	case leadingCenter
	case center
	case trailingCenter

	case bottomLeading
	case bottomCenter
	case bottomTrailing
}
