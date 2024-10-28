//
//  UIView+TraitCollection.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 20/05/2022.
//

import UIKit
import ObjectiveC.runtime

extension UIView {
	/// internal check to see if we have swizzled traitCollectionDidChange already. Since
	/// this should only be called on the main thread, this is a simple check.
	private static var hasSwizzledTraitCollectionDidChange = false
	
	/// the notification fired when a views `traitCollectionDidChange(_:)` is called. The notification's `object` is the view
	/// of which the trait collection did change.
	static internal let traitCollectionDidChange = Notification.Name("com.aveapps.AutoLayoutConvenience.TraitCollectionDidChange")
	
	/// internal function that swizzles `traitCollectionDidChange(_:)` to fire of a notification so that
	/// we can monitor when a view's trait collection changes.
	internal static func swizzleTraitCollectionDidChangeIfNeeded() {
		guard Self.hasSwizzledTraitCollectionDidChange == false else { return }
		Self.hasSwizzledTraitCollectionDidChange = true
		
		swizzleTraitCollectionDidChange(for: UIView.self)
		swizzleTraitCollectionDidChange(for: UIImageView.self)
		swizzleTraitCollectionDidChange(for: UILabel.self)
	}
	
	/// Monitors changes to trait collection of this view. You need to hold onto the return value; releasing it will stop the observation.
	public func monitorTraitCollectionChanges(_ callback: @escaping @MainActor () -> Void) -> Cancellable {
		Self.swizzleTraitCollectionDidChangeIfNeeded()
		
		let observer = NotificationCenter.default.addObserver(forName: Self.traitCollectionDidChange, object: self, queue: .main) { _ in
			MainActor.assumeIsolated {
				callback()
			}
		}
		return Cancellable(notificationCenterObserver: observer)
	}
	
	private static func swizzleTraitCollectionDidChange(for viewClass: AnyClass) {
		let selector = #selector(traitCollectionDidChange(_:))
		guard let originalMethod = class_getInstanceMethod(viewClass, selector) else { return }
		typealias OriginalFunction = @convention(c) (UIView, Selector, UITraitCollection?) -> Void
		var originalFunction: OriginalFunction?
		
		let block: @convention(block) (UIView, UITraitCollection?) -> Void = { view, traitCollection in
			originalFunction?(view, selector, traitCollection)
			NotificationCenter.default.post(name: UIView.traitCollectionDidChange, object: view)
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
