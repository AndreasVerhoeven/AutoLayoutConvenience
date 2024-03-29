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
	///		- distribution: **optional** distribution of the items, defaults to `.fill`
	///		- spacing: **optional** the spacing between the views
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given views
	public static func verticallyStacked(
		_ views: UIView...,
		alignment: UIStackView.Alignment = .fill,
		distribution: UIStackView.Distribution = .fill,
		spacing: CGFloat = 0,
		insets: NSDirectionalEdgeInsets? = nil
	) -> UIStackView {
		return verticallyStacked(
			views,
			alignment: alignment,
			distribution: distribution,
			spacing: spacing,
			insets: insets
		)
	}

	/// Wraps views in a vertically aligned UIStackView
	///
	/// - Parameters:
	///		- views: The list of views to add to the stack view
	///		- alignment: **optional** horizontal alignment, defaults to `.fill`
	///		- distribution: **optional** distribution of the items, defaults to `.fill`
	///		- spacing: **optional** the spacing between the views
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given views
	public static func verticallyStacked(
		_ views: [UIView],
		alignment: UIStackView.Alignment = .fill,
		distribution: UIStackView.Distribution = .fill,
		spacing: CGFloat = 0,
		insets: NSDirectionalEdgeInsets? = nil
	) -> UIStackView {
		return AutoHidingStackView(
			with: views,
			axis: .vertical,
			alignment: alignment,
			distribution: distribution,
			spacing: spacing,
			insets: insets
		)
	}

	/// Wraps views in a horizontally aligned UIStackView
	///
	/// - Parameters:
	///		- views: The list of views to add to the stack view
	///		- alignment: **optional** vertical alignment, defaults to `.fill`
	///		- distribution: **optional** distribution of the items, defaults to `.fill`
	///		- spacing: **optional** the spacing between the views
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given views
	public static func horizontallyStacked(
		_ views: UIView...,
		alignment: UIStackView.Alignment = .fill,
		distribution: UIStackView.Distribution = .fill,
		spacing: CGFloat = 0,
		insets: NSDirectionalEdgeInsets? = nil
	) -> UIStackView {
		return horizontallyStacked(
			views,
			alignment: alignment,
			distribution: distribution,
			spacing: spacing,
			insets: insets
		)
	}

	/// Wraps views in a horizontally aligned UIStackView
	///
	/// - Parameters:
	///		- views: The list of views to add to the stack view
	///		- alignment: **optional** vertical alignment, defaults to `.fill`
	///		- distribution: **optional** distribution of the items, defaults to `.fill`
	///		- spacing: **optional** the spacing between the views
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given views
	public static func horizontallyStacked(
		_ views: [UIView],
		alignment: UIStackView.Alignment = .fill,
		distribution: UIStackView.Distribution = .fill,
		spacing: CGFloat = 0,
		insets: NSDirectionalEdgeInsets? = nil
	) -> UIStackView {
		return AutoHidingStackView(
			with: views,
			axis: .horizontal,
			alignment: alignment,
			distribution: distribution,
			spacing: spacing,
			insets: insets
		)
	}

	/// Wraps views in a UIStackView
	///
	/// - Parameters:
	///		- views: The list of views to add to the stack view
	///		- alignment: **optional** alignment, defaults to `.fill`
	///		- distribution: **optional** distribution of the items, defaults to `.fill`
	///		- spacing: **optional** the spacing between the views
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given views
	public static func stacked(
		_ views: UIView...,
		axis: NSLayoutConstraint.Axis,
		alignment: UIStackView.Alignment = .fill,
		distribution: UIStackView.Distribution = .fill,
		spacing: CGFloat = 0,
		insets: NSDirectionalEdgeInsets? = nil
	) -> UIStackView {
		return stacked(
			views,
			axis: axis,
			alignment: alignment,
			distribution: distribution,
			spacing: spacing,
			insets: insets
		)
	}

	/// Wraps views in a UIStackView
	///
	/// - Parameters:
	///		- views: The list of views to add to the stack view
	///		- axis: the axis to align along
	///		- alignment: **optional** alignment, defaults to `.fill`
	///		- distribution: **optional** distribution of the items, defaults to `.fill`
	///		- spacing: **optional** the spacing between the views
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given views
	public static func stacked(
		_ views: [UIView],
		axis: NSLayoutConstraint.Axis,
		alignment: UIStackView.Alignment = .fill,
		distribution: UIStackView.Distribution = .fill,
		spacing: CGFloat = 0,
		insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return AutoHidingStackView(
			with: views,
			axis: axis,
			alignment: .fill,
			distribution: distribution,
			spacing: spacing,
			insets: insets
		)
	}

	/// Horizontally aligns a single view by wrapping it in a properly aligned UIStackView
	///
	/// - Parameters:
	///		- view: The view to align
	///		- alignment: the alignment to use
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given view
	public static func horizontally(_ view: UIView, alignment: UIStackView.Alignment, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return AutoHidingStackView(with: view, axis: .vertical, alignment: alignment, insets: insets)
	}

	/// Horizontally aligns `self` by wrapping it in a properly aligned UIStackView
	///
	/// - Parameters:
	///		- view: The view to align
	///		- alignment: the alignment to use
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView`
	public func horizontally(aligned: UIStackView.Alignment, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return Self.horizontally(self, alignment: aligned, insets: insets)
	}

	/// Horizontally centers a view by wrapping it in a properly aligned UIStackView
	///
	/// - Parameters:
	///		- view: The view to align
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView`
	public static func horizontallyCentered(_ view: UIView, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return horizontally(view, alignment: .center, insets: insets)
	}

	/// Horizontally centers `self` by wrapping it in a properly aligned UIStackView
	///
	/// - Parameters:
	///		- view: The view to align
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView`
	public func horizontallyCentered(insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
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
	public static func vertically(_ view: UIView, alignment: UIStackView.Alignment, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return AutoHidingStackView(with: view, axis: .horizontal, alignment: alignment, insets: insets)
	}

	/// Vertically aligns `self` by wrapping it in a properly aligned UIStackView
	///
	/// - Parameters:
	///		- view: The view to align
	///		- alignment: the alignment to use
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView`
	public func vertically(aligned: UIStackView.Alignment, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		Self.vertically(self, alignment: aligned, insets: insets)
	}

	/// Vertically centers a view by wrapping it in a properly aligned UIStackView
	///
	/// - Parameters:
	///		- view: The view to align
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView`
	public static func verticallyCentered(_ view: UIView, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return vertically(view, alignment: .center, insets: insets)
	}


	/// Vertically centers `self` by wrapping it in a properly aligned UIStackView
	///
	/// - Parameters:
	///		- view: The view to align
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView`
	public func verticallyCentered(insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
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
	public static func aligned(_ view: UIView,  horizontally: UIStackView.Alignment = .fill, vertically: UIStackView.Alignment = .fill, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
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
	public func aligned(horizontally: UIStackView.Alignment = .fill, vertically: UIStackView.Alignment = .fill, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return Self.aligned(self,  horizontally: horizontally, vertically: vertically, insets: insets)
	}

	/// Centers a single view by wrapping it in a two properly aligned `UIStackView`s
	///
	/// - Parameters:
	///		- view: The view to center
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given view
	public static func centered(_ view: UIView, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return aligned(view,  horizontally: .center, vertically: .center, insets: insets)
	}

	/// Centers `self` by wrapping it in a two properly aligned `UIStackView`s
	///
	/// - Parameters:
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given view
	public func centered(insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return Self.centered(self, insets: insets)
	}

	/// Insets a view by wrapping it in a properly insetted `UIStackView`
	///
	/// - Parameters:
	///		- insets: the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given view
	public static func insetted(_ view: UIView, by insets: NSDirectionalEdgeInsets) -> UIStackView {
		return AutoHidingStackView(with: view, axis: .vertical, insets: insets)
	}

	/// Insets `self` by wrapping it in a properly insetted `UIStackView`
	///
	/// - Parameters:
	///		- insets: the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given view
	public func insetted(by insets: NSDirectionalEdgeInsets) -> UIStackView {
		return Self.insetted(self, by: insets)
	}

	/// Wraps views in a vertically aligned UIStackView that auto adjust to a horizontal stackview if the
	/// horizontal size class is compact.
	///
	/// - Parameters:
	///		- views: The list of views to add to the stack view
	///		- alignment: **optional** horizontal alignment, defaults to `.fill`
	///		- distribution: **optional** distribution of the items, defaults to `.fill`
	///		- spacing: **optional** the spacing between the views
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given views
	public static func autoAdjustingVerticallyStacked(_ views: UIView..., alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill, spacing: CGFloat = 0, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return autoAdjustingVerticallyStacked(views, alignment: alignment, distribution: distribution, spacing: spacing, insets: insets)
	}

	/// Wraps views in a vertically aligned UIStackView that auto adjust to a horizontal stackview if the
	/// horizontal size class is compact.
	///
	/// - Parameters:
	///		- views: The list of views to add to the stack view
	///		- alignment: **optional** horizontal alignment, defaults to `.fill`
	///		- distribution: **optional** distribution of the items, defaults to `.fill`
	///		- spacing: **optional** the spacing between the views
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given views
	public static func autoAdjustingVerticallyStacked(_ views: [UIView], alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill, spacing: CGFloat = 0, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return AutoAdjustingVerticalStackView(with: views, alignment: alignment, distribution: distribution, spacing: spacing, insets: insets)
	}

	/// Wraps views in a horizontally aligned UIStackView that auto adjust to a vertical stackview if the
	/// horizontal size class is compact.
	///
	/// - Parameters:
	///		- views: The list of views to add to the stack view
	///		- alignment: **optional** vertical alignment, defaults to `.fill`
	///		- distribution: **optional** distribution of the items, defaults to `.fill`
	///		- spacing: **optional** the spacing between the views
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given views
	public static func autoAdjustingHorizontallyStacked(_ views: UIView..., alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill, spacing: CGFloat = 0, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return autoAdjustingHorizontallyStacked(views, alignment: alignment, distribution: distribution, spacing: spacing, insets: insets)
	}

	/// Wraps views in a horizontally aligned UIStackView that auto adjust to a vertical stackview if the
	/// horizontal size class is compact.
	///
	/// - Parameters:
	///		- views: The list of views to add to the stack view
	///		- alignment: **optional** vertical alignment, defaults to `.fill`
	///		- distribution: **optional** distribution of the items, defaults to `.fill`
	///		- spacing: **optional** the spacing between the views
	///		- insets: **optional** the inset to apply to the stack view
	///
	/// - Returns: the created `UIStackView` with the given views
	public static func autoAdjustingHorizontallyStacked(_ views: [UIView], alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill, spacing: CGFloat = 0, insets: NSDirectionalEdgeInsets? = nil) -> UIStackView {
		return AutoAdjustingHorizontalStackView(with: views, alignment: alignment, distribution: distribution, spacing: spacing, insets: insets)
	}
}
