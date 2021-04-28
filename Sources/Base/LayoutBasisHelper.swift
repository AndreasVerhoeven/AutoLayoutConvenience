//
//  LayoutBasisHelper.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 25/04/2021.
//

import UIKit

// MARK: - Layout Protocols
protocol BaseLayout {
	init(_ all: LayoutAnchorable)
	func retargeted(to view: UIView?) -> Self
}

protocol SingleAxisLayout: BaseLayout {
	var axis: LayoutAnchorable { get }
}

// MARK: - BaseLayout Factory methods
extension BaseLayout {
	static var none: Self { Self(.none) }

	/// Anchored to the `default` anchorable, usually `superview`
	static var `default`: Self { Self(.default) }

	/// Anchored to the `superview` of the relevant view
	static var superview: Self { Self(.superview) }

	/// Anchored to a specified other view that is a relative
	/// (they share the same superview somewhere in the hierarchy)
	/// than the relevant view
	static func relative(_ view: UIView) -> Self { Self(.relative(view)) }

	/// Anchored to a specific `UILayoutGuide`
	static func guide(_ guide: UILayoutGuide) -> Self { Self(.guide(guide)) }

	/// Anchored to the `safeAreaLayoutGuide` of the relevant view
	static var safeArea: Self { Self(.safeArea) }

	/// Anchored to the `safeAreaLayoutGuide` of a specific view
	static func safeAreaOf(_ view: UIView) -> Self { Self(.safeAreaOf(view)) }

	/// Anchored to the `layoutMarginsGuide` of the relevant view
	static var layoutMargins: Self { Self(.layoutMargins) }

	/// Anchored to the `layoutMarginsGuide` of a specific view
	static func layoutMarginsOf(_ view: UIView) -> Self { Self(.layoutMarginsOf(view)) }

	/// Anchored to the `readableContentLayoutGuide` of the relevant view
	static var readableContent: Self { Self(.readableContent) }

	/// Anchored to the `readableContentLayoutGuide` of the specific view
	static func readableContentOf(_ view: UIView) -> Self { Self(.readableContentOf(view)) }

	/// Anchored to the `contentLayoutGuide` of the relevant view if
	/// that view is a `UIScrollView`, otherwise anchored to the relevant view
	static var scrollContent: Self { Self(.scrollContent) }

	/// Anchored to the `contentLayoutGuide` of the specified `UIScrollView`
	static func scrollContentOf(_ view: UIScrollView) -> Self { Self(.scrollContentOf(view)) }

	/// Anchored to the `frameLayoutGuide` of the relevant view if
	/// that view is a `UIScrollView`, otherwise anchored to the relevant view
	static var scrollFrame: Self { Self(.scrollFrame) }

	/// Anchored to the `frameLayoutGuide` of the specified `UIScrollView`
	static func scrollFrameOf(_ view: UIScrollView) -> Self { Self(.scrollFrameOf(view)) }
}

// MARK: - Layout Factories
extension BoxLayout: BaseLayout {
	/// Creates a layout where each axis uses the same anchorable
	static func horizontally(_ horizontally: HorizontalAxisLayout, vertically: VerticalAxisLayout) -> BoxLayout {
		return Self(top: vertically.top, leading: horizontally.leading, bottom: vertically.bottom, trailing: horizontally.trailing)
	}

	/// Creates a layout where each anchorable is defined manually
	static func top(_ top: LayoutAnchorable, leading: LayoutAnchorable, bottom: LayoutAnchorable, trailing: LayoutAnchorable) -> BoxLayout {
		return Self(top: top, leading: leading, bottom: bottom, trailing: trailing)
	}
}

extension HorizontalAxisLayout: BaseLayout {
	/// Creates a layout for specific leading and trailing anchorables
	static func leading(_ leading: LayoutAnchorable, trailing: LayoutAnchorable) -> Self { Self(leading: leading, trailing: trailing) }
}

extension VerticalAxisLayout: BaseLayout {
	/// Creates a layout for specific top and bottom anchorables
	static func top(_ top: LayoutAnchorable, bottom: LayoutAnchorable) -> Self { Self(top: top, bottom: bottom) }
}

extension PointLayout: BaseLayout {
	/// Creates a layout for specific x and y anchorables
	static func x(_ x: LayoutAnchorable, y: LayoutAnchorable) -> Self { Self(x: x, y: y) }
}

extension XAxisLayout: SingleAxisLayout {
	/// Creates a layout for a specific x anchorable
	static func x(_ x: LayoutAnchorable) -> Self { Self(x: x) }
}

extension YAxisLayout: SingleAxisLayout {
	/// Creates a layout for a specific y anchorable
	static func y(_ y: LayoutAnchorable) -> Self { Self(y: y) }
}


// MARK: - Layout Helpers

extension SingleAxisLayout {
	func retargeted(to view: UIView?) -> Self {
		return Self(axis.retargeted(to: view))
	}
}

extension BoxLayout {
	init(_ all: LayoutAnchorable) { self.init(top: all, leading: all, bottom: all, trailing: all) }

	func retargeted(to view: UIView?) -> Self {
		return Self(top: top.retargeted(to: view), leading: leading.retargeted(to: view), bottom: bottom.retargeted(to: view), trailing: trailing.retargeted(to: view))
	}
}

extension HorizontalAxisLayout {
	init(_ all: LayoutAnchorable) { self.init(leading: all, trailing: all) }
	func retargeted(to view: UIView?) -> Self { Self(leading: leading.retargeted(to: view), trailing: trailing.retargeted(to: view)) }
}

extension VerticalAxisLayout {
	init(_ all: LayoutAnchorable) { self.init(top: all, bottom: all) }
	func retargeted(to view: UIView?) -> Self { Self(top: top.retargeted(to: view), bottom: bottom.retargeted(to: view)) }
}

extension PointLayout {
	init(_ all: LayoutAnchorable) { self.init(x: all, y: all) }
	func retargeted(to view: UIView?) -> Self { Self(x: x.retargeted(to: view), y: y.retargeted(to: view)) }
}

extension XAxisLayout {
	init(_ all: LayoutAnchorable) {self.init(x: all) }
	var axis: LayoutAnchorable {x}
}

extension YAxisLayout {
	init(_ all: LayoutAnchorable) {self.init(y: all) }
	var axis: LayoutAnchorable {y}
}

// MARK: - Layout Anchorable Implementation
extension LayoutAnchorable {
	/// Returns the LayoutAnchorsProvider we can use to perform layout
	internal func layoutAnchorsProvider(in baseView: UIView?) -> LayoutAnchorsProvider? {
		switch self {
			case .none: return nil
			case .default: return UIView.Default.Resolved.layoutAnchorable.layoutAnchorsProvider(in: baseView)
			case .superview: return baseView

			case .relative(let view): return view
			case .guide(let guide): return guide

			case .safeArea: return baseView?.safeAreaLayoutGuide
			case .safeAreaOf(let view): return view.safeAreaLayoutGuide

			case .layoutMargins: return baseView?.layoutMarginsGuide
			case .layoutMarginsOf(let view): return view.layoutMarginsGuide

			case .readableContent: return baseView?.readableContentGuide
			case .readableContentOf(let view): return view.readableContentGuide

			case .scrollContent: return (baseView as? UIScrollView)?.contentLayoutGuide ?? baseView
			case .scrollContentOf(let scrollView): return scrollView.contentLayoutGuide

			case .scrollFrame: return (baseView as? UIScrollView)?.frameLayoutGuide ?? baseView
			case .scrollFrameOf(let scrollView): return scrollView.frameLayoutGuide
		}
	}
}

// Mark: - LayoutAnchorable Helpers
extension LayoutAnchorable {
	/// Returns the same layout, but for another view
	internal func retargeted(to view: UIView?) -> Self {
		guard let view = view else { return self }
		switch self {
			case .none: return self
			case .default: return self
			case .superview: return .superview
			case .relative: return .relative(view)
			case .guide: return .relative(view)

			case .safeArea, .safeAreaOf: return .safeAreaOf(view)
			case .layoutMargins, .layoutMarginsOf: return .layoutMarginsOf(view)
			case .readableContent, .readableContentOf: return .readableContentOf(view)

			case .scrollContent, .scrollContentOf:
				guard let scrollView = view as? UIScrollView else { return .relative(view)}
				return  .scrollContentOf(scrollView)

			case .scrollFrame, .scrollFrameOf:
				guard let scrollView = view as? UIScrollView else { return .relative(view)}
				return  .scrollFrameOf(scrollView)
		}
	}

	/// Returns true if this is the default layout
	internal var isDefault: Bool {
		if case .default = self {
			return true
		} else {
			return false
		}
	}

	/// Returns the view that we will base layout on
	internal func targetedView(in baseView: UIView?) -> UIView? {
		let provider = layoutAnchorsProvider(in: baseView)
		return (provider as? UILayoutGuide)?.owningView ?? provider as? UIView
	}

	/// check if the same view is targeted
	func isForSameView(as view: UIView?) -> Bool {
		return targetedView(in: view) == view
	}
}

// MARK: - ConstrainedLayout Factory Methods
extension ConstrainedLayout {
	/// No layout
	static var none: Self { Self(.none) }

	/// Use the default layout
	static var `default`: Self { Self(.default) }

	/// Attach the layout to the view we are pinned to instead of the superview
	static var attach: Self { Self(.attached(nil))}

	/// Attach a specific layout to the view we are pinned to instead of the superview
	static func attached(_ layout: Self) -> Self { Self(.attached(layout)) }

	/// fill from edge to edge
	static var fill: Self { Self(.fill(nil)) }

	/// fill another layout from edge to edge
	static func filling(_ other: FillLayout) -> Self { Self(.fill(other)) }

	/// center in the axis
	static var center: Self { Self(.center(nil)) }

	/// centered in some other axis
	static func centered(in other: MainAxisLayout) -> Self { centered(in: other, between: FillLayout.init(other.axis)) }

	/// centered in some other axis while being constrained by the `between` layout
	static func centered(in other: MainAxisLayout, between: FillLayout) -> Self { Self(.center(CenteredLayout(center: other, fill: between))) }

	/// don't constrain the layout, let it overflow if needed
	static func overflow(_ value: Self) -> Self { Self(operation: value.operation, constrained: false) }
}

extension ConstrainedLayout where FillLayout == HorizontalAxisLayout {
	/// Align to the leading edge
	static var leading: Self { Self(operation: .start(nil)) }

	/// Align to the leading edge in another layout
	static func leading(in other: FillLayout) -> Self { Self(.start(other)) }

	/// Align to the trailing edge
	static var trailing: Self { Self(operation: .end(nil)) }

	/// Align to the trailing edge in another layout
	static func trailing(in other: FillLayout) -> Self { Self(.end(other)) }
}

extension ConstrainedLayout where FillLayout == VerticalAxisLayout {
	/// Align to the top edge
	static var top: Self { Self(operation: .start(nil)) }

	/// Align to the top edge in another layout
	static func top(in other: FillLayout) -> Self { Self(.start(other)) }

	/// Align to the bottom edge
	static var bottom: Self { Self(operation: .end(nil)) }

	/// Align to the bottom edge in another layout
	static func bottom(in other: FillLayout) -> Self { Self(.end(other)) }
}

// MARK: - ConstrainedLayout Helpers
extension ConstrainedLayout {
	private init(_ operation: Operation) {
		self.init(operation: operation)
	}

	internal var isAttached: Bool {
		switch operation {
			case .attached: return true
			case .default, .center, .start, .end, .fill, .none: return false
		}
	}

	internal var isDefault: Bool {
		switch operation {
			case .default: return true
			case .attached, .center, .start, .end, .fill, .none: return false
		}
	}

	internal var isPassThru: Bool {
		return (isDefault == true || isAttached == true)
	}

	internal static func usableFillLayout(for layout: FillLayout?, others: [SingleAxisLayout], view: UIView?) -> FillLayout {
		if let layout = layout {
			return layout
		} else if let other = others.first, other.axis.isForSameView(as: view) == true {
			return FillLayout(other.axis.retargeted(to: view))
		} else {
			return .default
		}
	}

	internal static func usableCenterLayout(for center: MainAxisLayout?, others: [SingleAxisLayout], view: UIView?) -> MainAxisLayout {
		if let center = center {
			return center
		} else if let other = others.first, other.axis.isForSameView(as: view) == true {
			return MainAxisLayout(other.axis.retargeted(to: view))
		} else {
			return .default
		}
	}
}

// MARK: - Position & Edge Helpers
extension LayoutPosition {

	/// Gets the appropriate vertical layout anchor for this position
	internal func xAnchor(for provider: LayoutAnchorsProvider?) -> NSLayoutYAxisAnchor? {
		switch self {
			case .topLeading, .topCenter, .topTrailing: return provider?.topAnchor
			case .leadingCenter, .center, .trailingCenter: return provider?.centerYAnchor
			case .bottomLeading, .bottomCenter, .bottomTrailing: return provider?.bottomAnchor
		}
	}

	/// Gets the appropriate horizontal layout anchor for this position
	internal func yAnchor(for provider: LayoutAnchorsProvider?) -> NSLayoutXAxisAnchor? {
		switch self {
			case .topLeading, .leadingCenter, .bottomLeading: return provider?.leadingAnchor
			case .topCenter,  .center, .bottomCenter: return provider?.centerXAnchor
			case .topTrailing, .trailingCenter, .bottomTrailing: return provider?.trailingAnchor
		}
	}
}

extension HorizontalLayoutEdge {
	/// Gets the appropriate layout anchor to use for layout
	internal func anchor(for provider: LayoutAnchorsProvider?) -> NSLayoutXAxisAnchor? {
		switch self {
			case .leading: return provider?.leadingAnchor
			case .centerX: return provider?.centerXAnchor
			case .trailing: return provider?.trailingAnchor
		}
	}

	/// Gets the effective value to use for the layout anchor's constant for the given `insets`
	internal func effectiveInset(for insets: NSDirectionalEdgeInsets) -> CGFloat {
		switch self {
			case .leading: return insets.leading
			case .centerX: return -(insets.leading - insets.trailing)
			case .trailing: return -insets.trailing
		}
	}

	/// Gets the effective value to use for the layout anchor's constant for the given `spacing`
	internal func effectiveSpacing(for spacing: CGFloat) -> CGFloat {
		switch self {
			case .leading: return -spacing
			case .centerX: return spacing
			case .trailing: return spacing
		}
	}
}

extension VerticalLayoutEdge {
	/// Gets the appropriate layout anchor to use for layout
	internal func anchor(for provider: LayoutAnchorsProvider?) -> NSLayoutYAxisAnchor? {
		switch self {
			case .top: return provider?.topAnchor
			case .centerY: return provider?.centerYAnchor
			case .bottom: return provider?.bottomAnchor
		}
	}

	/// Gets the effective value to use for the layout anchor's constant for the given `insets`
	internal func effectiveInset(for insets: NSDirectionalEdgeInsets) -> CGFloat {
		switch self {
			case .top: return -insets.top
			case .centerY: return -(insets.top - insets.bottom)
			case .bottom: return insets.bottom
		}
	}

	/// Gets the effective value to use for the layout anchor's constant for the given `spacing`
	internal func effectiveSpacing(for spacing: CGFloat) -> CGFloat {
		switch self {
			case .top: return -spacing
			case .centerY: return spacing
			case .bottom: return spacing
		}
	}
}

