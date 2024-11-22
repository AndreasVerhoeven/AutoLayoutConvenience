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
	///		- `avoidsKeyboard`: **optional** if true, will make the scrollview avoid the keyboard (defaults to false)
	///		- showsScrollIndicator: **optional** if false, the scroll indicators will be hidden. Defaults to `true`.
	///
	///	- Returns: A VerticalOverflowScrollView with view embedded in it
	static public func verticallyScrollable(_ view: UIView, horizontally: HorizontalAxisLayout = .superview, avoidsKeyboard: Bool = false, showsScrollIndicator: Bool = true) -> VerticalOverflowScrollView {
		let scrollView = VerticalOverflowScrollView(with: view, horizontally: horizontally, adjustsForKeyboard: avoidsKeyboard)
		if showsScrollIndicator == false {
			scrollView.showsVerticalScrollIndicator = false
		}

		return scrollView
	}

	/// Embeds `self` in a vertically scrollable view
	///
	/// - Parameters:
	///		- horizontally: **optional** the axis to constrain horizontally to, defaults to `.superview`
	///		- `avoidsKeyboard`: **optional** if true, will make the scrollview avoid the keyboard (defaults to false)
	///		- showsScrollIndicator: **optional** if false, the scroll indicators will be hidden. Defaults to `true`.
	///
	///	- Returns: A VerticalOverflowScrollView with `self` embedded in it
	public func verticallyScrollable(horizontally: HorizontalAxisLayout = .superview, avoidsKeyboard: Bool = false, showsScrollIndicator: Bool = true) -> VerticalOverflowScrollView {
		Self.verticallyScrollable(self, horizontally: horizontally, avoidsKeyboard: avoidsKeyboard, showsScrollIndicator: showsScrollIndicator)
	}

	/// Embeds a view in a horizontally scrollable view
	///
	/// - Parameters:
	///		- view: the view to embed
	///		- vertically: **optional** the axis to constrain vertically to, defaults to `.superview`
	///		- showsScrollIndicator: **optional** if false, the scroll indicators will be hidden. Defaults to `true`.
	///
	///	- Returns: A HorizontalOverflowScrollView with view embedded in it
	static public func horizontallyScrollable(_ view: UIView, vertically: VerticalAxisLayout = .superview, showsScrollIndicator: Bool = true) -> HorizontalOverflowScrollView {
		let scrollView = HorizontalOverflowScrollView(with: view, vertically: vertically)
		if showsScrollIndicator == false {
			scrollView.showsHorizontalScrollIndicator = false
		}
		return scrollView
	}

	/// Embeds `self` in a horizontally scrollable view
	///
	/// - Parameters:
	///		- vertically: **optional** the axis to constrain vertically to, defaults to `.superview`
	///		- showsScrollIndicator: **optional** if false, the scroll indicators will be hidden. Defaults to `true`.
	///
	///	- Returns: A HorizontalOverflowScrollView with `self` embedded in it
	public func horizontallyScrollable(vertically: VerticalAxisLayout = .superview, showsScrollIndicator: Bool = true) -> HorizontalOverflowScrollView {
		Self.horizontallyScrollable(self, vertically: vertically, showsScrollIndicator: showsScrollIndicator)
	}

	/// Returns the first scrollview in the hierarchy that has isScrollEnabled set to true
	public var firstScrollableView: UIScrollView? {
		if let scrollView = self as? UIScrollView, scrollView.isScrollEnabled == true {return scrollView
		} else {
			return subviews.lazy.compactMap { $0.firstScrollableView }.first
		}
	}
}
