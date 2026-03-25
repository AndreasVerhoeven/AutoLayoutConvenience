//
//  AxisAndAlignment.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 25/03/2026.
//

import UIKit

extension UIStackView {
	/// Combines UIStackView alignment with the axis we want to align on
	public struct AxisAndAlignment {
		/// the axis we want to align on
		public var axis: NSLayoutConstraint.Axis

		/// the alignment we want to use
		public var alignment: UIStackView.Alignment

		init(axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment) {
			self.axis = axis
			self.alignment = alignment
		}

		// MARK: Helpers

		/// vertical alignment
		public static func vertically(_ alignment: UIStackView.Alignment) -> Self {
			return Self(axis: .vertical, alignment: alignment)
		}

		/// horizontal alignment
		public static func horizontally(_ alignment: UIStackView.Alignment) -> Self {
			return Self(axis: .horizontal, alignment: alignment)
		}

		// MARK: Vertical

		/// vertical fill
		public static let verticalFill = Self(axis: .vertical, alignment: .fill)

		/// vertical top
		public static let top = Self(axis: .vertical, alignment: .top)

		/// vertical center
		public static let centerY = Self(axis: .vertical, alignment: .center)

		/// vertical bottom
		public static let bottom = Self(axis: .vertical, alignment: .bottom)

		/// vertical first base line
		public static let firstBaseline = Self(axis: .vertical, alignment: .firstBaseline)

		/// vertical last baseline
		public static let lastBaseline = Self(axis: .vertical, alignment: .lastBaseline)

		// MARK: Horizontal

		/// horizontal fill
		public static let horizontalFill = Self(axis: .horizontal, alignment: .fill)

		/// horizontal leading
		public static let leading = Self(axis: .horizontal, alignment: .leading)

		/// horizontal center
		public static let centerX = Self(axis: .horizontal, alignment: .center)

		/// horizontal trailing
		public static let trailing = Self(axis: .horizontal, alignment: .trailing)
	}
}

extension UIStackView.AxisAndAlignment {
	internal var stackViewAxisToApply: NSLayoutConstraint.Axis {
		// this is inverted, because to align vertically in a stack view (e.g. to top),
		// the stack view needs to lay out it subviews horizontally
		switch axis {
			case .horizontal: return .vertical
			case .vertical: return .horizontal
			@unknown default: return axis
		}
	}
}
