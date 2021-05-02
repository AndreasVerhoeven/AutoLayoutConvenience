//
//  UIView+Scrollable.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 28/04/2021.
//

import UIKit

extension UIView {
	/// Embeds a view in a vertically scrollable view
	///
	/// - Parameters:
	///		- view: the view to embed
	///		- horizontally: **optional** the axis to constrain horizontally to, defaults to `.superview`
	///
	///	- Returns: A VerticalOverflowScrollView with view embedded in it
	static public func verticallyScrollable(_ view: UIView, horizontally: HorizontalAxisLayout = .superview) -> VerticalOverflowScrollView {
		return VerticalOverflowScrollView(with: view, horizontally: horizontally)
	}

	/// Embeds `self` in a vertically scrollable view
	///
	/// - Parameters:
	///		- horizontally: **optional** the axis to constrain horizontally to, defaults to `.superview`
	///
	///	- Returns: A VerticalOverflowScrollView with `self` embedded in it
	public func verticallyScrollable(horizontally: HorizontalAxisLayout = .superview) -> VerticalOverflowScrollView {
		Self.verticallyScrollable(self, horizontally: horizontally)
	}

	/// Embeds a view in a horizontally scrollable view
	///
	/// - Parameters:
	///		- view: the view to embed
	///		- vertically: **optional** the axis to constrain vertically to, defaults to `.superview`
	///
	///	- Returns: A HorizontalOverflowScrollView with view embedded in it
	static public func horizontallyScrollable(_ view: UIView, vertically: VerticalAxisLayout = .superview) -> HorizontalOverflowScrollView {
		return HorizontalOverflowScrollView(with: view, vertically: vertically)
	}

	/// Embeds `self` in a horizontally scrollable view
	///
	/// - Parameters:
	///		- vertically: **optional** the axis to constrain vertically to, defaults to `.superview`
	///
	///	- Returns: A HorizontalOverflowScrollView with `self` embedded in it
	public func horizontallyScrollable(vertically: VerticalAxisLayout = .superview) -> HorizontalOverflowScrollView {
		Self.horizontallyScrollable(self, vertically: vertically)
	}

	/// Returns the first scrollview in the hierarchy that has isScrollEnabled set to true
	public var firstScrollableView: UIScrollView? {
		if let scrollView = self as? UIScrollView, scrollView.isScrollEnabled == true {return scrollView
		} else {
			return subviews.lazy.compactMap { $0.firstScrollableView }.first
		}
	}
}
