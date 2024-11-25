//
//  UIView+DynamicConstantSize.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 24/11/2024.
//

import UIKit
import ObjectiveC.runtime

extension UIView {
	/// This sets a fixed width constraint that is being remembered. Reassigning this
	/// updates the existing width constraint or create a new one.
	///
	/// Use this to set a fixed width that you can update easily.
	public var constrainedFixedWidth: CGFloat? {
		get {
			return fixedWidthConstraint?.constant
		}
		set {
			let constraint = fixedWidthConstraint
			guard constraint?.constant != newValue else { return }

			if let newValue {
				if let constraint {
					constraint.constant = newValue
				} else {
					let newConstraint = widthAnchor.constraint(equalToConstant: newValue)
					fixedWidthConstraint = newConstraint
					newConstraint.isActive = true
				}
			} else if constraint != nil {
				constraint?.isActive = false
				fixedWidthConstraint = nil
			}
		}
	}

	/// This sets a fixed height constraint that is being remembered. Reassigning this
	/// updates the existing height constraint or create a new one.
	///
	/// Use this to set a fixed height that you can update easily.
	public var constrainedFixedHeight: CGFloat? {
		get {
			return fixedHeightConstraint?.constant
		}
		set {
			let constraint = fixedHeightConstraint
			guard constraint?.constant != newValue else { return }

			if let newValue {
				if let constraint {
					constraint.constant = newValue
				} else {
					let newConstraint = heightAnchor.constraint(equalToConstant: newValue)
					fixedHeightConstraint = newConstraint
					newConstraint.isActive = true
				}
			} else if constraint != nil {
				constraint?.isActive = false
				fixedHeightConstraint = nil
			}
		}
	}

	/// This sets fixed size constraints that are being remembered. Reassigning this
	/// updates the existing constraints or create new ones.
	///
	/// Use this to set a fixed size that you can update easily.
	public var constrainedFixedSize: CGSize? {
		get {
			guard let constrainedFixedWidth, let constrainedFixedHeight else { return nil }
			return CGSize(width: constrainedFixedWidth, height: constrainedFixedHeight)
		}
		set {
			constrainedFixedWidth = newValue?.width
			constrainedFixedHeight = newValue?.height
		}
	}

	// MARK: - Privates
	fileprivate static var constrainedFixedWidthConstraintKey = 0
	fileprivate var fixedWidthConstraint: NSLayoutConstraint? {
		get { objc_getAssociatedObject(self, &Self.constrainedFixedWidthConstraintKey) as? NSLayoutConstraint }
		set { objc_setAssociatedObject(self, &Self.constrainedFixedWidthConstraintKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}

	fileprivate static var constrainedFixedHeightConstraintKey = 0
	fileprivate var fixedHeightConstraint: NSLayoutConstraint? {
		get { objc_getAssociatedObject(self, &Self.constrainedFixedHeightConstraintKey) as? NSLayoutConstraint }
		set { objc_setAssociatedObject(self, &Self.constrainedFixedHeightConstraintKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}
}
