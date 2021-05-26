//
//  UIView+SizeConstraints.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 26/05/2021.
//

import UIKit

public enum SizeConstrainType {
	case atLeast
	case exactly
	case atMost
}

public struct SizeConstrain<T> {
	public var type: SizeConstrainType
	public var value: T
	public var priority: UILayoutPriority = .required

	/// Makes the view at least the given size, but not smaller
	public static func atLeast(_ value: T, priority: UILayoutPriority = .required) -> Self {
		return Self.init(type: .atLeast, value: value, priority: priority)
	}

	/// Makes the view exactly the given size
	public static func exactly(_ value: T, priority: UILayoutPriority = .required) -> Self {
		return Self.init(type: .exactly, value: value, priority: priority)
	}

	/// Makes the view atMost the given size, but not larger
	public static func atMost(_ value: T, priority: UILayoutPriority = .required) -> Self {
		return Self.init(type: .atMost, value: value, priority: priority)
	}
}

extension UIView {
	/// Constrains this view to a given `size`
	///
	/// - Parameters:
	///  - size: the constrained size, one of .atLeast, .exactly, .atMost
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func constrain(size: SizeConstrain<CGSize>) -> Self {
		return constrain(width: SizeConstrain(type: size.type, value: size.value.width, priority: size.priority),
						 height: SizeConstrain(type: size.type, value: size.value.height, priority: size.priority))
	}

	/// Constrains this view to a given `width` and `height`
	///
	/// - Parameters:
	///  - width: **optional** the constrained width, one of .atLeast, .exactly, .atMost
	///  - height: **optional** the constrained width, one of .atLeast, .exactly, .atMost
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func constrain(width: SizeConstrain<CGFloat>? = nil, height: SizeConstrain<CGFloat>? = nil) -> Self {
		ConstraintsList.activate([
			width.flatMap({ $0.layoutConstraint(for: widthAnchor) }),
			height.flatMap({ $0.layoutConstraint(for: heightAnchor) }),
		])
		return self
	}
}


extension SizeConstrain where T == CGFloat {
	func layoutConstraint(for anchor: NSLayoutDimension) -> NSLayoutConstraint {
		switch type {
			case .atLeast:
				return anchor.constraint(greaterThanOrEqualToConstant: value)

			case .exactly:
				return anchor.constraint(equalToConstant: value)

			case .atMost:
				return anchor.constraint(lessThanOrEqualToConstant: value)
		}
	}
}

