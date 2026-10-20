//
//  UIScrollView+AdditionalContentInsets.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 20/10/2026.
//

import UIKit
import ObjectiveC.runtime

public extension UIScrollView {
	/// Conform to this to be informed whenever `additionalContentInsets` changes, so that you can
	/// fold the new value into your own content inset computation instead of it being silently ignored.
	/// Either conform to this on the scroll view itself, or set `handlerForAdditionalContentInsets`
	/// to some other object that should be notified instead.
	protocol AdditionalContentsInsetsHandler: AnyObject {
		/// called whenever `additionalContentInsets` changes, with the new value.
		func handleAdditionalContentInsets(_ insets: UIEdgeInsets)
	}

	/// the handler to notify when `additionalContentInsets` changes, in case it's not the scroll view
	/// itself that conforms to `AdditionalContentsInsetsHandler`. Held weakly, so it doesn't need to
	/// be cleared manually.
	var handlerForAdditionalContentInsets: AdditionalContentsInsetsHandler? {
		get { (objc_getAssociatedObject(self, &Self.handlerForAdditionalContentInsetsKey) as? WeakAdditionalContentInsetsHandlerBox)?.handler }
		set { objc_setAssociatedObject(self, &Self.handlerForAdditionalContentInsetsKey, WeakAdditionalContentInsetsHandlerBox(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}

	/// Extra room to reserve at the top and bottom of the scroll view's content, on top of whatever
	/// else manages its content insets. Setting this calls `handleAdditionalContentInsets(_:)` on the
	/// scroll view itself (if it conforms to `AdditionalContentsInsetsHandler`) and/or on
	/// `handlerForAdditionalContentInsets`, so either can fold the value into its own layout.
	/// Only `top` and `bottom` are meant to be used; `left` and `right` are not interpreted by anyone.
	var additionalContentInsets: UIEdgeInsets {
		get { objc_getAssociatedObject(self, &Self.additionalContentInsetsKey) as? UIEdgeInsets ?? .zero }
		set {
			guard newValue != additionalContentInsets else { return }
			objc_setAssociatedObject(self, &Self.additionalContentInsetsKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			(self as? AdditionalContentsInsetsHandler)?.handleAdditionalContentInsets(newValue)
			handlerForAdditionalContentInsets?.handleAdditionalContentInsets(newValue)
		}
	}

	// MARK: - Privates
	private static var additionalContentInsetsKey = 0
	private static var handlerForAdditionalContentInsetsKey = 0
}

/// box used to hold a weak reference to a `UIScrollView.AdditionalContentsInsetsHandler`,
/// since associated objects cannot store weak references directly.
private final class WeakAdditionalContentInsetsHandlerBox {
	weak var handler: UIScrollView.AdditionalContentsInsetsHandler?

	init(_ handler: UIScrollView.AdditionalContentsInsetsHandler?) {
		self.handler = handler
	}
}
