//
//  UIView+ManualLayoutBridging.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 27/05/2021.
//

import UIKit

/// Determines how `autoLayoutSizeThatFits()` works exactly.
public struct ManualLayoutSizeThatFitsBridgingMode: Sendable {
	/// Determines how a dimension in the bridges sizeThatFits can grow
	public enum Dimension: Sendable {
		/// The dimension should be fixed to the given size. If size == .greatestFiniteMagnitude, we'll try to be as small as possible
		case fixed

		/// The dimension should be smaller than the given size, if possible. If size == .greatestFiniteMagnitude, we'll try to be as small as possible
		case bounded

		var fittingPriority: UILayoutPriority {
			switch self {
				case .fixed: return .required
				case .bounded: return .defaultLow
			}
		}

		var shouldUseCompressedSize: Bool {
			switch self {
				case .fixed: return false
				case .bounded: return true
			}
		}
	}

	/// The horizontal bridging mode
	public var horizontal: Dimension = .fixed

	/// The vertical bridging mode
	public var vertical: Dimension = .fixed

	/// Creates a bridging mode
	public init(horizontal: Dimension, vertical: Dimension) {
		self.horizontal = horizontal
		self.vertical = vertical
	}

	/// the width should be the same as the passed in width, the height should not exceed the passed in height, but can be smaller
	public static let fixedWidth = Self(horizontal: .fixed, vertical: .bounded)

	/// the height should be the same as the passed in height, the width should not exceed the passed in width, but can be smaller
	public static let fixedHeight = Self(horizontal: .bounded, vertical: .fixed)

	/// The view should have the exact same dimensions as the passed in size, if possible
	public static let fixedSize = Self(horizontal: .fixed, vertical: .fixed)

	/// The view should be smaller than the given dimensions, if possible
	public static let boundedSize = Self(horizontal: .bounded, vertical: .bounded)
}

extension UIView {
	/// Helper method to implement sizeThatFits() for AutoLayout views: it forwards to systemLayoutSizeFitting()
	///
	/// - Parameters:
	///		- size: the size we want to fit in
	///		- bridgingMode: **optional** the bridging mode to use, determines in what directions the view can grow and which dimesions should be fixed
	///	- Returns: the size that fits
	public func autoLayoutSizeThatFits(_ size: CGSize, bridgingMode: ManualLayoutSizeThatFitsBridgingMode = .fixedSize) -> CGSize {
		var horizontalLayoutPriority = bridgingMode.horizontal.fittingPriority
		var verticalFittingPriority = bridgingMode.vertical.fittingPriority

		var targetSize = size
		if targetSize.width == .greatestFiniteMagnitude || bridgingMode.horizontal.shouldUseCompressedSize == true {
			targetSize.width = UIView.layoutFittingCompressedSize.width
			horizontalLayoutPriority = .defaultLow

		}

		if targetSize.height == .greatestFiniteMagnitude || bridgingMode.vertical.shouldUseCompressedSize == true {
			targetSize.height = UIView.layoutFittingCompressedSize.height
			verticalFittingPriority = .defaultLow
		}

		var fittingSize = systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalLayoutPriority, verticalFittingPriority: verticalFittingPriority)

		if bridgingMode.vertical.shouldUseCompressedSize == true {
			fittingSize.height = min(fittingSize.height, size.height)
		}

		if bridgingMode.horizontal.shouldUseCompressedSize == true {
			fittingSize.width = min(fittingSize.width, size.width)
		}
		return fittingSize
	}
}

/// A view that helps with bridging auto layout to manual layout:
///
/// This view can be used in a manual layout setting, while doing auto layout inside of it:
/// it implements sizeThatFits() by forwarding to `autoLayoutSizeThatFits()`
public class AutoLayoutHostedInManualLayoutBridgingView: UIView {
	/// Callback that will be called when the auto layout view requires layout. If not set,
	/// will call setNeedsLayout() on self and superview.
	public var layoutCallback: LayoutCallback?
	public typealias LayoutCallback = () -> Void
	
	/// Set this view to how you want the default implementation of sizeThatFits() work
	public var sizeThatFitsBridgingMode: ManualLayoutSizeThatFitsBridgingMode = .fixedSize

	/// Creates a simple bridging view without any contents
	public convenience init(sizeThatFitsBridgingMode: ManualLayoutSizeThatFitsBridgingMode, backgroundColor: UIColor? = nil) {
		self.init(frame: .zero)
		self.sizeThatFitsBridgingMode = sizeThatFitsBridgingMode
		self.backgroundColor = backgroundColor
	}
	
	/// Creates a bridging view that holds an AutoLayout view and that can be used in Manual Layout. When the AutoLayout view needs new layout, it'll call setNeedsLayout() on the bridging view
	/// and its superview or call the layoutCallback.
	public convenience init(view: UIView, sizeThatFitsBridgingMode: ManualLayoutSizeThatFitsBridgingMode = .boundedSize, layoutCallback: LayoutCallback? = nil) {
		self.init(frame: .zero)
		self.sizeThatFitsBridgingMode = sizeThatFitsBridgingMode
		self.translatesAutoresizingMaskIntoConstraints = false
		self.layoutCallback = layoutCallback
		
		let stackView = CallbackStackView(axis: .horizontal, alignment: .fill, distribution: .fillProportionally)
		stackView.callback = { [weak self] in self?.update() }
		stackView.addArrangedSubviews(view)
		addSubview(stackView, filling: .superview)
	}
	
	public override class var requiresConstraintBasedLayout: Bool { true }
	
	// MARK: - Privates
	private var isInLayoutCallbackInSetNeedsLayoutCount = 0
	
	private class CallbackStackView: UIStackView {
		var callback: (() -> Void)?
		override func updateConstraints() {
			super.updateConstraints()
			callback?()
		}
		
		override func setNeedsLayout() {
			super.setNeedsLayout()
			callback?()
		}
	}
	
	private func update() {
		if let layoutCallback = layoutCallback {
			layoutCallback()
		} else {
			setNeedsLayout()
			superview?.setNeedsLayout()
		}
	}
	
	public override func setNeedsLayout() {
		super.setNeedsLayout()
		
		if let layoutCallback = layoutCallback {
			isInLayoutCallbackInSetNeedsLayoutCount += 1
			if isInLayoutCallbackInSetNeedsLayoutCount == 1 {
				layoutCallback()
			}
			isInLayoutCallbackInSetNeedsLayoutCount -= 1
		}
	}

	// MARK: - UIView
	// this is private API, unfortunately:
//	@objc func _intrinsicContentSizeInvalidatedForChildView(_ x: UIView) {
//		setNeedsLayout()
//		if UIView.inheritedAnimationDuration > 0 {
//			layoutIfNeeded()
//		}
//	}
	
	public override func sizeThatFits(_ size: CGSize) -> CGSize {
		return autoLayoutSizeThatFits(size, bridgingMode: sizeThatFitsBridgingMode)
	}
}
