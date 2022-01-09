//
//  UIView+SizeConstraints.swift
//  AutoLayoutConvenience
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
			width.flatMap({ $0.layoutConstraint(for: widthAnchor).with(priority: $0.priority) }),
			height.flatMap({ $0.layoutConstraint(for: heightAnchor).with(priority: $0.priority) }),
		])
		return self
	}

	/// Constrains this view to that width is between `widthRange` and its height is between `heightRange`
	///
	/// - Parameters:
	///	 - widthRange: **optional** the range we want the width to be between
	///	 - heightRange: **optional** the range we want the height to be between
	///  - priority: **optional** the priority for the constraints, defaults to `.required`
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func constrain(widthBetween widthRange: Range<CGFloat>? = nil,
											 heightBetween heightRange: Range<CGFloat>? = nil,
											 priority: UILayoutPriority = .required) -> Self {
		let scale = UIScreen.main.scale
		let pixelSize = scale > 0 ? (1 / scale) : 1

		let closedWidthRange = widthRange.flatMap { $0.lowerBound...$0.upperBound - pixelSize  }
		let closedHeightRange = heightRange.flatMap { $0.lowerBound...$0.upperBound - pixelSize  }
		return constrain(widthBetween: closedWidthRange, heightBetween: closedHeightRange, priority: priority)
	}

	/// Constrains this view to that width is between `widthRange` and its height is between `heightRange`
	///
	/// - Parameters:
	///	 - widthRange: **optional** the range we want the width to be between
	///	 - heightRange: **optional** the range we want the height to be between
	///  - priority: **optional** the priority for the constraints, defaults to `.required`
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func constrain(widthBetween widthRange: ClosedRange<CGFloat>? = nil,
											 heightBetween heightRange: ClosedRange<CGFloat>? = nil,
											 priority: UILayoutPriority = .required) -> Self {
		var constraints = [NSLayoutConstraint]()
		if let widthRange = widthRange {
			constraints += [
				widthAnchor.constraint(greaterThanOrEqualToConstant: widthRange.lowerBound).with(priority: priority),
				widthAnchor.constraint(lessThanOrEqualToConstant: widthRange.upperBound).with(priority: priority),
			]
		}

		if let heightRange = heightRange {
			constraints += [
				heightAnchor.constraint(greaterThanOrEqualToConstant: heightRange.lowerBound).with(priority: priority),
				heightAnchor.constraint(lessThanOrEqualToConstant: heightRange.upperBound).with(priority: priority),
			]
		}

		NSLayoutConstraint.activate(constraints)
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
