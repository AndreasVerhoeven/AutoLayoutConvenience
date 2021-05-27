//
//  UIView+ManualLayoutBridging.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 27/05/2021.
//

import UIKit

/// Determines how `autoLayoutSizeThatFits()` works exactly.
public struct ManualLayoutSizeThatFitsBridgingMode {
	/// Determines how a dimension in the bridges sizeThatFits can grow
	public enum Dimension {
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
	}

	/// The horizontal bridging mode
	public var horizontal: Dimension = .fixed

	/// The vertical bridging mode
	public var vertical: Dimension = .fixed

	/// The view should have the same width as the passed in width, but horizontally we should be smaller than the given size
	public static var fixedWidth = Self(horizontal: .fixed, vertical: .bounded)

	/// The view should have the same height as the passed in height, but verticallt we should be smaller than the given size
	public static var fixedHeight = Self(horizontal: .bounded, vertical: .fixed)

	/// The view should have the exact same dimensions as the view, if possible
	public static var fixedSize = Self(horizontal: .fixed, vertical: .fixed)
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
		if targetSize.width == .greatestFiniteMagnitude {
			targetSize.width = UIView.layoutFittingCompressedSize.width
			horizontalLayoutPriority = .defaultLow

		}

		if targetSize.height == .greatestFiniteMagnitude {
			targetSize.height = UIView.layoutFittingCompressedSize.height
			verticalFittingPriority = .defaultLow
		}

		return systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalLayoutPriority, verticalFittingPriority: verticalFittingPriority)
	}
}

/// A view that helps with bridging auto layout to manual layout:
///
/// This view can be used in a manual layout setting, while doing auto layout inside of it:
/// it implements sizeThatFits() by forwarding to `autoLayoutSizeThatFits()`
public class ManualLayoutBridgedView: UIView {
	public var sizeThatFitsBridgingMode: ManualLayoutSizeThatFitsBridgingMode { .fixedSize }

	// MARK: - UIView
	
	/* this is private API, unfortunately:
	@objc func _intrinsicContentSizeInvalidatedForChildView(_ x: UIView) {
		setNeedsLayout()
		if UIView.inheritedAnimationDuration > 0 {
			layoutIfNeeded()
		}
	}
	*/

	public override func sizeThatFits(_ size: CGSize) -> CGSize {
		return autoLayoutSizeThatFits(size, bridgingMode: sizeThatFitsBridgingMode)
	}
}
