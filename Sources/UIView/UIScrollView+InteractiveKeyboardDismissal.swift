//
//  UIScrollView+InteractiveKeyboardDismissal.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 04/02/2025.
//

import UIKit

extension UIScrollView {
	/// internal check to see if we have swizzled traitCollectionDidChange already. Since
	/// this should only be called on the main thread, this is a simple check.
	private static var hasSwizzledKeyboardDismissMode = false

	/// internal function that swizzles `traitCollectionDidChange(_:)` to fire of a notification so that
	/// we can monitor when a view's trait collection changes.
	internal static func swizzleKeyboardDismissModeIfNeeded() {
		guard Self.hasSwizzledKeyboardDismissMode == false else { return }
		Self.hasSwizzledKeyboardDismissMode = true

		swizzleKeyboardDismissMode(for: UIScrollView.self)
	}

	private static func swizzleKeyboardDismissMode(for viewClass: AnyClass) {
		let selector = #selector(setter: keyboardDismissMode)
		guard let originalMethod = class_getInstanceMethod(viewClass, selector) else { return }
		typealias OriginalFunction = @convention(c) (UIScrollView, Selector, UIScrollView.KeyboardDismissMode) -> Void
		var originalFunction: OriginalFunction?

		let block: @convention(block) (UIScrollView, UIScrollView.KeyboardDismissMode) -> Void = { scrollView, keyboardDismissMode in
			let originalValue = scrollView.keyboardDismissMode
			originalFunction?(scrollView, selector, keyboardDismissMode)

			guard originalValue != keyboardDismissMode else { return }
			switch keyboardDismissMode {
				case .interactive, .interactiveWithAccessory:
					KeyboardTracker.shared.trackInteractiveKeyboardDismissal(in: scrollView)

				case .none, .onDrag, .onDragWithAccessory:
					KeyboardTracker.shared.stopTrackingInteractiveKeyboardDismissal(for: scrollView)

				@unknown default:
					break
			}
		}
		let newImplementation = imp_implementationWithBlock(block)
		let originalImplementation: IMP
		if(!class_addMethod(viewClass, selector, newImplementation, method_getTypeEncoding(originalMethod))) {
			originalImplementation = method_setImplementation(originalMethod, newImplementation)
		} else {
			originalImplementation = method_getImplementation(originalMethod)
		}
		originalFunction = unsafeBitCast(originalImplementation, to: OriginalFunction.self)
	}
}

