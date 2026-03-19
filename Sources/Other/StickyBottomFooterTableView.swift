//
//  StickyBottomFooterTableView.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 20/02/2024.
//

import UIKit

/// Legacy implementation of `StickyFooterTableView`. All old methods are available,
/// but forward to `stickyFooterView`.
///
/// Please use `StickyFooterTableView` instead.
@available(*, deprecated, message: "Use StickyFooterTableView")
public class StickyBottomFooterTableView: StickyFooterTableView {
	public var stickyFooterBackgroundColor: UIColor? {
		get { stickyFooterView.stickingBackgroundColor }
		set { stickyFooterView.stickingBackgroundColor = newValue }
	}

	public var stickyFooterBlurEffect: UIBlurEffect? {
		get { stickyFooterView.stickingBlurEffect }
		set { stickyFooterView.stickingBlurEffect = newValue }
	}

	public var stickyFooterUsesScrollEdgeElement: Bool {
		get { stickyFooterView.stickingUsesScrollEdgeElement }
		set { stickyFooterView.stickingUsesScrollEdgeElement = newValue }
	}

	public var stickingState: StickyFooterView.State {
		get { stickyFooterView.state }
	}

	public var footerStickinessChangedCallback: (() -> Void)? {
		get { stickyFooterView.stateDidChangeCallback }
		set { stickyFooterView.stateDidChangeCallback = newValue }
	}

	public var stickyFooterMode: StickyFooterView.Mode {
		get { stickyFooterView.mode }
		set { stickyFooterView.mode = newValue }
	}

	public var stickyFooterAvoidsKeyboard: Bool {
		get { stickyFooterView.avoidsKeyboard }
		set { stickyFooterView.avoidsKeyboard = newValue }
	}

	public var stickyFooterSpacingToKeyboard: CGFloat {
		get { stickyFooterView.spacingToKeyboard }
		set { stickyFooterView.spacingToKeyboard = newValue }
	}

	public var stickyFooterRequiredAvailableContentHeight: CGFloat {
		get { stickyFooterView.requiredAvailableScrollableContentHeight }
		set { stickyFooterView.requiredAvailableScrollableContentHeight = newValue }
	}

	public var stickyFooterTableContentAlignment: StickyFooterView.ScrollableContentVerticalAlignment {
		get { stickyFooterView.fittingScrollableContentVerticalAlignment }
		set { stickyFooterView.fittingScrollableContentVerticalAlignment = newValue }
	}
}
