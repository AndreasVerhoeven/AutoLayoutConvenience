//
//  UIView+ConditionalInternal.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 20/05/2022.
//

import UIKit

extension UIView {
	/// internal function to monitor
	private static var hasSwizzledTraitCollectionDidChange = false
	
	static internal let traitCollectionDidChange = Notification.Name("com.aveapps.AutoLayoutConvenience.TraitCollectionDidChange")
	
	/// internal function that swizzles `traitCollectionDidChange(_:)` to fire of a notification
	internal static func swizzleTraitCollectionDidChangeIfNeeded() {
		guard Self.hasSwizzledTraitCollectionDidChange == false else { return }
		Self.hasSwizzledTraitCollectionDidChange = true
		
		let selector = #selector(traitCollectionDidChange(_:))
		guard let originalMethod = class_getInstanceMethod(UIView.self, selector) else { return }
		typealias OriginalFunction = @convention(c) (UIView, Selector, UITraitCollection?) -> Void
		var originalFunction: OriginalFunction?
		
		let block: @convention(block) (UIView, UITraitCollection?) -> Void = { view, traitCollection in
			originalFunction?(view, selector, traitCollection)
			NotificationCenter.default.post(name: Self.traitCollectionDidChange, object: view)
		}
		let newImplementation = imp_implementationWithBlock(block)
		let originalImplementation: IMP
		if(!class_addMethod(UIView.self, selector, newImplementation, method_getTypeEncoding(originalMethod))) {
			originalImplementation = method_setImplementation(originalMethod, newImplementation)
		} else {
			originalImplementation = method_getImplementation(originalMethod)
		}
		originalFunction = unsafeBitCast(originalImplementation, to: OriginalFunction.self)
	}
}
