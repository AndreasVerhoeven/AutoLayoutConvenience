//
//  LayoutBasisHelper.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 25/04/2021.
//

import UIKit

// MARK: - Layout Protocols
public protocol BaseLayout {
	init(_ all: LayoutAnchorable)
	func retargeted(to view: UIView?) -> Self
}

public protocol SingleAxisLayout: BaseLayout, Equatable {
	var axis: LayoutAnchorable { get }
	static func layoutDimension(in layoutAnchorsProvider: LayoutAnchorsProvider) -> NSLayoutDimension
}

// MARK: - BaseLayout Factory methods
public extension BaseLayout {
	static var none: Self {
		return Self(.none)
	}

	/// Anchored to the `default` anchorable, usually `superview`
	static var `default`: Self {
		return Self(.default)
	}

	/// Anchored to the `superview` of the relevant view
	static var superview: Self {
		return Self(.superview)
	}

	/// Anchored to a specified other view that is a relative
	/// (they share the same superview somewhere in the hierarchy)
	/// than the relevant view
	static func relative(_ view: UIView) -> Self {
		return Self(.relative(view))
	}

	/// Anchored to a specific `UILayoutGuide`
	static func guide(_ guide: UILayoutGuide) -> Self {
		return Self(.guide(guide))
	}

	/// Anchored to the `safeAreaLayoutGuide` of the relevant view
	static var safeArea: Self {
		return Self(.safeArea)
	}

	/// Anchored to the `safeAreaLayoutGuide` of a specific view
	static func safeAreaOf(_ view: UIView) -> Self {
		return Self(.safeAreaOf(view))
	}

	/// Anchored to the `layoutMarginsGuide` of the relevant view
	static var layoutMargins: Self {
		return Self(.layoutMargins)
	}

	/// Anchored to the `layoutMarginsGuide` of a specific view
	static func layoutMarginsOf(_ view: UIView) -> Self {
		return Self(.layoutMarginsOf(view))
	}

	/// Anchored to the `readableContentLayoutGuide` of the relevant view
	static var readableContent: Self {
		return Self(.readableContent)
	}

	/// Anchored to the `readableContentLayoutGuide` of the specific view
	static func readableContentOf(_ view: UIView) -> Self {
		return Self(.readableContentOf(view))
	}

	/// Anchored to the `contentLayoutGuide` of the relevant view if
	/// that view is a `UIScrollView`, otherwise anchored to the relevant view
	static var scrollContent: Self {
		return Self(.scrollContent)
	}

	/// Anchored to the `contentLayoutGuide` of the specified `UIScrollView`
	static func scrollContentOf(_ view: UIScrollView) -> Self {
		return Self(.scrollContentOf(view))
	}

	/// Anchored to the `frameLayoutGuide` of the relevant view if
	/// that view is a `UIScrollView`, otherwise anchored to the relevant view
	static var scrollFrame: Self {
		return Self(.scrollFrame)
	}

	/// Anchored to the `frameLayoutGuide` of the specified `UIScrollView`
	static func scrollFrameOf(_ view: UIScrollView) -> Self {
		return Self(.scrollFrameOf(view))
	}

	/// Anchored to the custom `keyboardSafeAreaLayoutGuide` of the relevant view
	static var keyboardSafeArea: Self {
		return Self(.keyboardSafeArea)
	}

	/// Anchored to the custom `keyboardSafeAreaLayoutGuide` of a specific view
	static func keyboardSafeAreaOf(_ view: UIView) -> Self {
		return Self(.keyboardSafeAreaOf(view))
	}

	/// Anchored to the custom `keyboardFrameLayoutGuide` of the relevant view
	static var keyboardFrame: Self {
		return Self(.keyboardFrame)
	}

	/// Anchored to the custom `keyboardFrameLayoutGuide` of a specific view
	static func keyboardFrameOf(_ view: UIView) -> Self {
		return Self(.keyboardFrameOf(view))
	}
	
	/// Anchored to the leading side of the area that is excluded by the specific excludable area (.e.g safeArea)
	static func excludedLeadingSideOf(_ area: ExcludableArea) -> Self {
		return Self(.excludedLeadingSideOf(area))
	}
	
	/// Anchored to the trailing side of the area that is excluded by the specific excludable area (.e.g safeArea)
	static func excludedTrailingSideOf(_ area: ExcludableArea) -> Self {
		return Self(.excludedTrailingSideOf(area))
	}
	
	/// Anchored to the top side of the area that is excluded by the specific excludable area (.e.g safeArea)
	static func excludedTopSideOf(_ area: ExcludableArea) -> Self {
		return Self(.excludedTopSideOf(area))
	}
	
	/// Anchored to the bottom side of the area that is excluded by the specific excludable area (.e.g safeArea)
	static func excludedBottomSideOf(_ area: ExcludableArea) -> Self {
		return Self(.excludedBottomSideOf(area))
	}
}

// MARK: - Layout Factories
extension BoxLayout: BaseLayout {
	/// Creates a layout where each axis uses the same anchorable
	public static func horizontally(_ horizontally: HorizontalAxisLayout, vertically: VerticalAxisLayout) -> BoxLayout {
		return Self(top: vertically.top, leading: horizontally.leading, bottom: vertically.bottom, trailing: horizontally.trailing)
	}

	/// Creates a layout where each anchorable is defined manually
	public static func top(_ top: LayoutAnchorable, leading: LayoutAnchorable, bottom: LayoutAnchorable, trailing: LayoutAnchorable) -> BoxLayout {
		return Self(top: top, leading: leading, bottom: bottom, trailing: trailing)
	}

	/// Creates a layout with `top` defined and all other edges set to `others`
	public static func top(_ top: LayoutAnchorable, others: LayoutAnchorable) -> BoxLayout {
		return Self(top: top, leading: others, bottom: others, trailing: others)
	}

	/// Creates a layout with `leading` defined and all other edges set to `others`
	public static func leading(_ leading: LayoutAnchorable, others: LayoutAnchorable) -> BoxLayout {
		return Self(top: others, leading: leading, bottom: others, trailing: others)
	}

	/// Creates a layout with `bottom` defined and all other edges set to `others`
	public static func bottom(_ bottom: LayoutAnchorable, others: LayoutAnchorable) -> BoxLayout {
		return Self(top: others, leading: others, bottom: bottom, trailing: others)
	}

	/// Creates a layout with `trailing` defined and all other edges set to `others`
	public static func trailing(_ trailing: LayoutAnchorable, others: LayoutAnchorable) -> BoxLayout {
		return Self(top: others, leading: others, bottom: others, trailing: trailing)
	}
}

extension HorizontalAxisLayout: BaseLayout {
	/// Creates a layout for specific leading and trailing anchorables
	public static func leading(_ leading: LayoutAnchorable, trailing: LayoutAnchorable) -> Self {
		return Self(leading: leading, trailing: trailing)
	}
}

extension VerticalAxisLayout: BaseLayout {
	/// Creates a layout for specific top and bottom anchorables
	public static func top(_ top: LayoutAnchorable, bottom: LayoutAnchorable) -> Self {
		return Self(top: top, bottom: bottom)
	}
}

extension PointLayout: BaseLayout {
	/// Creates a layout for specific x and y anchorables
	public static func x(_ x: LayoutAnchorable, y: LayoutAnchorable) -> Self {
		return Self(x: x, y: y)
	}
}

extension XAxisLayout: SingleAxisLayout {
	/// Creates a layout for a specific x anchorable
	public static func x(_ x: LayoutAnchorable) -> Self {
		return Self(x: x)
	}
	
	public static func layoutDimension(in layoutAnchorsProvider: LayoutAnchorsProvider) -> NSLayoutDimension {
		return layoutAnchorsProvider.widthAnchor
	}
}

extension YAxisLayout: SingleAxisLayout {
	/// Creates a layout for a specific y anchorable
	public static func y(_ y: LayoutAnchorable) -> Self {
		return Self(y: y)
	}
	
	public static func layoutDimension(in layoutAnchorsProvider: LayoutAnchorsProvider) -> NSLayoutDimension {
		return layoutAnchorsProvider.heightAnchor
	}
}


// MARK: - Layout Helpers

extension SingleAxisLayout {
	public func retargeted(to view: UIView?) -> Self {
		return Self(axis.retargeted(to: view))
	}
}

public extension BoxLayout {
	init(_ all: LayoutAnchorable) {
		self.init(top: all, leading: all, bottom: all, trailing: all)
	}

	func retargeted(to view: UIView?) -> Self {
		return Self(top: top.retargeted(to: view), leading: leading.retargeted(to: view), bottom: bottom.retargeted(to: view), trailing: trailing.retargeted(to: view))
	}
}

public extension HorizontalAxisLayout {
	init(_ all: LayoutAnchorable) {
		self.init(leading: all, trailing: all)
	}

	func retargeted(to view: UIView?) -> Self {
		return Self(leading: leading.retargeted(to: view), trailing: trailing.retargeted(to: view))
	}
}

public extension VerticalAxisLayout {
	init(_ all: LayoutAnchorable) {
		self.init(top: all, bottom: all)
	}

	func retargeted(to view: UIView?) -> Self {
		return Self(top: top.retargeted(to: view), bottom: bottom.retargeted(to: view))
	}
}

public extension PointLayout {
	init(_ all: LayoutAnchorable) {
		self.init(x: all, y: all)
	}

	func retargeted(to view: UIView?) -> Self {
		return Self(x: x.retargeted(to: view), y: y.retargeted(to: view))
	}
}

public extension XAxisLayout {
	init(_ all: LayoutAnchorable) {
		self.init(x: all)
	}

	var axis: LayoutAnchorable {
		return x
	}
}

public extension YAxisLayout {
	init(_ all: LayoutAnchorable) {
		self.init(y: all)
	}

	var axis: LayoutAnchorable {
		return y
	}
}

// MARK: - Layout Anchorable Implementation
extension LayoutAnchorable {
	/// Returns the LayoutAnchorsProvider we can use to perform layout
	public func layoutAnchorsProvider(in baseView: UIView?) -> LayoutAnchorsProvider? {
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

			case .keyboardSafeArea: return baseView?.keyboardSafeAreaLayoutGuide
			case .keyboardSafeAreaOf(let view): return view.keyboardSafeAreaLayoutGuide

			case .keyboardFrame: return baseView?.keyboardFrameLayoutGuide
			case .keyboardFrameOf(let view): return view.keyboardFrameLayoutGuide
				
			case .excludedTopSideOf(let area): return area.excludableLayoutGuides(in: baseView)?.top
			case .excludedBottomSideOf(let area): return area.excludableLayoutGuides(in: baseView)?.bottom
			case .excludedLeadingSideOf(let area): return area.excludableLayoutGuides(in: baseView)?.leading
			case .excludedTrailingSideOf(let area): return area.excludableLayoutGuides(in: baseView)?.trailing
		}
	}
	
	/// converts this layout  anchorable to a YAxisLayout
	internal var yAxis: YAxisLayout {
		return YAxisLayout(y: self)
	}
	
	/// converts this layout  anchorable to a XAxisLayout
	internal var xAxis: XAxisLayout {
		return XAxisLayout(x: self)
	}
}

// MARK: - ExcludableArea Helpers
extension ExcludableArea {
	internal func excludableLayoutGuides(in baseView: UIView?) -> UIView.ExcludedAreaLayoutGuides? {
		switch self {
			case .layoutMargins: return baseView?.excludedByLayoutMarginsGuides
			case .layoutMarginsOf(let view): return view.excludedByLayoutMarginsGuides
				
			case .readableContent: return baseView?.unreadableContentLayoutGuides
			case .readableContentOf(let view): return view.unreadableContentLayoutGuides
				
			case .safeArea: return baseView?.unsafeAreaLayoutGuides
			case .safeAreaOf(let view): return view.unsafeAreaLayoutGuides
		}
	}
	
	internal func retargeted(to view: UIView?) -> Self {
		guard let view = view else { return self }
		
		switch self {
			case .layoutMargins, .layoutMarginsOf: return .layoutMarginsOf(view)
			case .readableContent, .readableContentOf: return .readableContentOf(view)
			case .safeArea, .safeAreaOf: return .safeAreaOf(view)
		}
	}
}

// MARK: - LayoutAnchorable Helpers
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

			case .keyboardSafeArea, .keyboardSafeAreaOf: return .keyboardSafeAreaOf(view)
			case .keyboardFrame, .keyboardFrameOf: return .keyboardFrameOf(view)
				
			case .excludedLeadingSideOf(let area): return .excludedLeadingSideOf(area.retargeted(to: view))
			case .excludedTrailingSideOf(let area): return .excludedTrailingSideOf(area.retargeted(to: view))
			case .excludedBottomSideOf(let area): return .excludedBottomSideOf(area.retargeted(to: view))
			case .excludedTopSideOf(let area): return .excludedTopSideOf(area.retargeted(to: view))
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
public extension ConstrainedLayout {
	/// No layout
	static var none: Self {
		return Self(.none)
	}

	/// Use the default layout
	static var `default`: Self {
		return Self(.default)
	}

	/// Attach the layout to the view we are pinned to instead of the superview
	static var attach: Self {
		return Self(.attached(nil))
	}

	/// Attach a specific layout to the view we are pinned to instead of the superview
	static func attached(_ layout: Self) -> Self {
		return Self(.attached(layout))
	}

	/// fill from edge to edge
	static var fill: Self {
		return Self(.fill(nil))
	}

	/// fill another layout from edge to edge
	static func filling(_ other: FillLayout) -> Self {
		return Self(.fill(other))
	}

	/// center in the axis
	static var center: Self {
		return Self(.center(nil))
	}

	/// centered in some other axis
	static func centered(in other: MainAxisLayout) -> Self {
		return centered(in: other, between: FillLayout.init(other.axis))
	}

	/// centered in some other axis while being constrained by the `between` layout
	static func centered(in other: MainAxisLayout, between: FillLayout) -> Self {
		return Self(.center(CenteredLayout(center: other, fill: between)))
	}

	/// don't constrain the layout, let it overflow if needed
	static func overflow(_ value: Self) -> Self {
		return Self(operation: value.operation, isConstrained: false)
	}
}

public extension ConstrainedLayout where FillLayout == HorizontalAxisLayout {
	/// Align to the leading edge
	static var leading: Self {
		return Self(operation: .start(nil))
	}

	/// Align to the leading edge in another layout
	static func leading(in other: FillLayout) -> Self {
		return Self(.start(other))
	}

	/// Align to the trailing edge
	static var trailing: Self {
		return Self(operation: .end(nil))
	}

	/// Align to the trailing edge in another layout
	static func trailing(in other: FillLayout) -> Self {
		return Self(.end(other))
	}
}

extension ConstrainedLayout where FillLayout == HorizontalAxisLayout, MainAxisLayout == XAxisLayout {
	fileprivate var resolved: Self {
		guard isDefault == true else { return self }
		return UIView.Default.Resolved.constrainedHorizontalLayout
	}
	
	internal func resolve(_ vertically: VerticalAxisLayout) -> Self {
		let value = resolved
		guard value.isSpecific == false else { return self }
		if vertically.top == vertically.bottom {
			return value.makeSpecific(HorizontalAxisLayout(vertically.top))
		} else {
			return .filling(.superview)
		}
	}
}

public extension ConstrainedLayout where FillLayout == VerticalAxisLayout {
	/// Align to the top edge
	static var top: Self {
		return Self(operation: .start(nil))
	}

	/// Align to the top edge in another layout
	static func top(in other: FillLayout) -> Self {
		return Self(.start(other))
	}

	/// Align to the bottom edge
	static var bottom: Self {
		return Self(operation: .end(nil))
	}

	/// Align to the bottom edge in another layout
	static func bottom(in other: FillLayout) -> Self {
		return Self(.end(other))
	}
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
	
	internal var isSpecific: Bool {
		switch operation {
			case .default, .none: return false
			case .attached: return false
			case .fill(let other): return other != nil
			case .center(let other): return other != nil
			case .start(let other): return other != nil
			case .end(let other): return other != nil
		}
	}
	
	internal static func usableFillLayout(for layout: FillLayout?, others: [any SingleAxisLayout], view: UIView?) -> FillLayout {
		if let layout = layout {
			return layout
		} else if let other = others.first, other.axis.isForSameView(as: view) == true {
			return FillLayout(other.axis.retargeted(to: view))
		} else {
			return .default
		}
	}

	internal static func usableCenterLayout(for center: MainAxisLayout?, others: [any SingleAxisLayout], view: UIView?) -> MainAxisLayout {
		if let center = center {
			return center
		} else if let other = others.first, other.axis.isForSameView(as: view) == true {
			return MainAxisLayout(other.axis.retargeted(to: view))
		} else {
			return .default
		}
	}
}

fileprivate protocol SingleAxisSegmentLayout: BaseLayout {
	var start: LayoutAnchorable { get }
	var end: LayoutAnchorable { get }
}

extension HorizontalAxisLayout: SingleAxisSegmentLayout {
	fileprivate var start: LayoutAnchorable { leading }
	fileprivate var end: LayoutAnchorable { trailing }
}

extension VerticalAxisLayout: SingleAxisSegmentLayout {
	fileprivate var start: LayoutAnchorable { top }
	fileprivate var end: LayoutAnchorable { bottom }
}

extension ConstrainedLayout where FillLayout: SingleAxisSegmentLayout {
	fileprivate func makeSpecific(_ other: FillLayout) -> Self {
		guard isSpecific == false else { return self }
		switch operation {
			case .default, .none: return self
			case .attached: return self
			case .fill: return .filling(other)
			case .center: return .centered(in: MainAxisLayout(other.start), between: other)
			case .start: return Self(.start(other))
			case .end: return Self(.end(other))
		}
	}
}


extension ConstrainedLayout where FillLayout == VerticalAxisLayout, MainAxisLayout == YAxisLayout {
	fileprivate var resolved: Self {
		guard isDefault == true else { return self }
		return UIView.Default.Resolved.constrainedVerticalLayout
	}
	
	internal func resolve(_ horizontally: HorizontalAxisLayout) -> Self {
		let value = resolved
		guard value.isSpecific == false else { return self }
		if horizontally.leading == horizontally.trailing {
			return value.makeSpecific(VerticalAxisLayout(horizontally.leading))
		} else {
			return .filling(.superview)
		}
	}
}

// MARK: - Position & Edge Helpers
extension LayoutPosition {

	/// Gets the appropriate vertical layout anchor for this position
	internal func yAnchor(for provider: LayoutAnchorsProvider?) -> NSLayoutYAxisAnchor? {
		switch self {
			case .topLeading, .topCenter, .topTrailing: return provider?.topAnchor
			case .leadingCenter, .center, .trailingCenter: return provider?.centerYAnchor
			case .bottomLeading, .bottomCenter, .bottomTrailing: return provider?.bottomAnchor
		}
	}

	/// Gets the appropriate horizontal layout anchor for this position
	internal func xAnchor(for provider: LayoutAnchorsProvider?) -> NSLayoutXAxisAnchor? {
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
