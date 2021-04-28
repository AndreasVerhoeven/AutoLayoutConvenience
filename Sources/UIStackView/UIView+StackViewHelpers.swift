//
//  UIStackView+AutoLayout.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 23/04/2021.
//

import UIKit

extension UIView {
	/// Wraps views in a vertically aligned UIStackView
	///
	/// - Parameters:
	///		- views: The list of views to add to the stack view
	///		- alignment: **optional** horizontal alignment, defaults to `.fill`
	///		- spacing: **optional** the spacing between the views
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given views
	static func verticallyStacked(_ views: UIView..., alignment: UIStackView.Alignment = .fill, spacing: CGFloat = 0, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return verticallyStacked(views, alignment: alignment, spacing: spacing, insets: insets)
	}

	/// Wraps views in a vertically aligned UIStackView
	///
	/// - Parameters:
	///		- views: The list of views to add to the stack view
	///		- spacing: **optional** the spacing between the views
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given views
	static func verticallyStacked(_ views: [UIView],  alignment: UIStackView.Alignment = .fill, spacing: CGFloat = 0, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		UIStackView(with: views, axis: .vertical, alignment: alignment, distribution: .fill, spacing: spacing, insets: insets)
	}

	/// Wraps views in a horizontally aligned UIStackView
	///
	/// - Parameters:
	///		- views: The list of views to add to the stack view
	///		- spacing: **optional** the spacing between the views
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given views
	static func horizontallyStacked(_ views: UIView..., spacing: CGFloat = 0, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return verticallyStacked(views, spacing: spacing, insets: insets)
	}

	/// Wraps views in a horizontally aligned UIStackView
	///
	/// - Parameters:
	///		- views: The list of views to add to the stack view
	///		- spacing: **optional** the spacing between the views
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given views
	static func horizontalllyStacked(_ views: [UIView], spacing: CGFloat = 0, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return UIStackView(with: views, axis: .horizontal, alignment: .fill, distribution: .fill, spacing: spacing, insets: insets)
	}

	/// Wraps views in a UIStackView
	///
	/// - Parameters:
	///		- views: The list of views to add to the stack view
	///		- spacing: **optional** the spacing between the views
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given views
	static func stacked(_ views: UIView...,  axis: NSLayoutConstraint.Axis, spacing: CGFloat = 0, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return stacked(views, axis: axis, spacing: spacing, insets: insets)
	}

	/// Wraps views in a UIStackView
	///
	/// - Parameters:
	///		- views: The list of views to add to the stack view
	///		- axis: the axis to align along
	///		- spacing: **optional** the spacing between the views
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given views
	static func stacked(_ views: [UIView],  axis: NSLayoutConstraint.Axis, spacing: CGFloat = 0, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return UIStackView(with: views, axis: axis, alignment: .fill, distribution: .fill, spacing: spacing, insets: insets)
	}

	/// Horizontally aligns a single view by wrapping it in a properly aligned UIStackView
	///
	/// - Parameters:
	///		- view: The view to align
	///		- alignment: the alignment to use
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given view
	static func horizontally(_ view: UIView, alignment: UIStackView.Alignment, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return UIStackView(with: view, axis: .vertical, alignment: alignment, insets: insets)
	}

	/// Horizontally aligns `self` by wrapping it in a properly aligned UIStackView
	///
	/// - Parameters:
	///		- view: The view to align
	///		- alignment: the alignment to use
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView`
	func horizontally(aligned: UIStackView.Alignment, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return Self.horizontally(self, alignment: aligned, insets: insets)
	}

	/// Horizontally centers a view by wrapping it in a properly aligned UIStackView
	///
	/// - Parameters:
	///		- view: The view to align
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView`
	static func horizontallyCentered(_ view: UIView, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return horizontally(view, alignment: .center)
	}

	/// Horizontally centers `self` by wrapping it in a properly aligned UIStackView
	///
	/// - Parameters:
	///		- view: The view to align
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView`
	func horizontallyCentered(insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return Self.horizontallyCentered(self, insets: insets)
	}

	/// Vertically aligns a single view by wrapping it in a properly aligned UIStackView
	///
	/// - Parameters:
	///		- view: The view to align
	///		- alignment: the alignment to use
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given view
	static func vertically(_ view: UIView, alignment: UIStackView.Alignment, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return UIStackView(with: view, axis: .horizontal, alignment: alignment, insets: insets)
	}

	/// Vertically aligns `self` by wrapping it in a properly aligned UIStackView
	///
	/// - Parameters:
	///		- view: The view to align
	///		- alignment: the alignment to use
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView`
	func vertically(aligned: UIStackView.Alignment, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		Self.vertically(self, alignment: aligned, insets: insets)
	}

	/// Vertically centers a view by wrapping it in a properly aligned UIStackView
	///
	/// - Parameters:
	///		- view: The view to align
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView`
	static func verticallyCentered(_ view: UIView, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return vertically(view, alignment: .center, insets: insets)
	}


	/// Vertically centers `self` by wrapping it in a properly aligned UIStackView
	///
	/// - Parameters:
	///		- view: The view to align
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView`
	func verticallyCentered(insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return Self.verticallyCentered(self, insets: insets)
	}

	/// Aligns a single view by wrapping it in a two properly aligned `UIStackView`s
	///
	/// - Parameters:
	///		- view: The view to align
	///		- horizontally: **optional** the horizontal alignment to use, defaults to `.fill`
	///		- vertically: **optional** the vertical alignment to use, defaults to `.fill`
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given view
	static func aligned(_ view: UIView, vertically: UIStackView.Alignment = .fill, horizontally: UIStackView.Alignment = .fill, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return self.vertically(self.horizontally(view, alignment: horizontally, insets: insets), alignment: vertically)
	}

	/// Aligns `self` by wrapping it in a two properly aligned `UIStackView`s
	///
	/// - Parameters:
	///		- view: The view to align
	///		- horizontally: **optional** the horizontal alignment to use, defaults to `.fill`
	///		- vertically: **optional** the vertical alignment to use, defaults to `.fill`
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given view
	func aligned(vertically: UIStackView.Alignment = .fill, horizontally: UIStackView.Alignment = .fill, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return Self.aligned(self, vertically: vertically, horizontally: horizontally, insets: insets)
	}

	/// Centers a single view by wrapping it in a two properly aligned `UIStackView`s
	///
	/// - Parameters:
	///		- view: The view to center
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given view
	static func centered(_ view: UIView, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return aligned(view, vertically: .center, horizontally: .center, insets: insets)
	}

	/// Centers `self` by wrapping it in a two properly aligned `UIStackView`s
	///
	/// - Parameters:
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given view
	func centered(insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return Self.centered(self, insets: insets)
	}

	/// Insets a view by wrapping it in a properly insetted `UIStackView`
	///
	/// - Parameters:
	///		- insets: the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given view
	static func insetted(_ view: UIView, by insets: NSDirectionalEdgeInsets) -> UIStackView {
		return UIStackView(with: view, axis: .vertical, insets: insets)
	}

	/// Insets `self` by wrapping it in a properly insetted `UIStackView`
	///
	/// - Parameters:
	///		- insets: the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given view
	func insetted(by insets: NSDirectionalEdgeInsets) -> UIStackView {
		return Self.insetted(self, by: insets)
	}
}
