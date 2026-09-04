//
//  UIView+ResizeNotifyWrapper.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 04/09/2026.
//

import UIKit

extension UIView {
	/// This wraps your view in another view, so that it can notify you via callback when it gets resized.
	///
	/// The view must be part of an AutoLayout hierarchy.
	///
	/// The inner workings are that the wrapper view monitors changes in its bounds in `layoutSubviews()`, and if it changes it calls the callback.
	/// Because we wrap `self` filling the wrapper completely, the wrapper will have the same size as `self`
	public func wrappedInResizeNotifier(_ callback: @escaping (_ size: CGSize) -> Void) -> UIView {
		final class WrapperView: UIView {
			var callback: ((CGSize) -> Void)?
			var lastKnownSize = CGSize.zero

			func invokeCallbackIfNeeded() {
				guard lastKnownSize != bounds.size else { return }
				lastKnownSize = bounds.size
				callback?(bounds.size)
			}

			// MARK: - UIView

			override func layoutSubviews() {
				super.layoutSubviews()
				invokeCallbackIfNeeded()
			}
		}

		let wrapperView = WrapperView()
		wrapperView.callback = callback
		wrapperView.addSubview(self, filling: .superview)
		return wrapperView
	}
}
