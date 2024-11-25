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

// Generic size constraint
public struct SizeConstrain<T> {
	public var type: SizeConstrainType
	public var value: T
	public var priority: UILayoutPriority = .required
	public var multiplier: CGFloat = 1
	public var constant: CGFloat = 0

	/// Makes the view at least the given size, but not smaller
	public static func atLeast(_ value: T, priority: UILayoutPriority = .required, multiplier: CGFloat = 1, constant: CGFloat = 0) -> Self {
		return Self.init(type: .atLeast, value: value, priority: priority, multiplier: multiplier, constant: constant)
	}

	/// Makes the view exactly the given size
	public static func exactly(_ value: T, priority: UILayoutPriority = .required, multiplier: CGFloat = 1, constant: CGFloat = 0) -> Self {
		return Self.init(type: .exactly, value: value, priority: priority, multiplier: multiplier, constant: constant)
	}

	/// Makes the view atMost the given size, but not larger
	public static func atMost(_ value: T, priority: UILayoutPriority = .required, multiplier: CGFloat = 1, constant: CGFloat = 0) -> Self {
		return Self.init(type: .atMost, value: value, priority: priority, multiplier: multiplier, constant: constant)
	}
}

extension SizeConstrain where T: SingleAxisLayout {
	/// Makes the view at exactly half of another layout.
	/// Note that the layout that is being referenced should already be in the same view hierarchy.
	public static func exactly(halfOf value: T, priority: UILayoutPriority = .required, constant: CGFloat = 0) -> Self {
		return exactly(value, priority: priority, multiplier: 0.5, constant: constant)
	}

	/// Makes the view at most half of another layout.
	/// Note that the layout that is being referenced should already be in the same view hierarchy.
	public static func atMost(halfOf value: T, priority: UILayoutPriority = .required, constant: CGFloat = 0) -> Self {
		return atMost(value, priority: priority, multiplier: 0.5, constant: constant)
	}

	/// Makes the view at least half of another layout.
	/// Note that the layout that is being referenced should already be in the same view hierarchy.
	public static func atLeast(halfOf value: T, priority: UILayoutPriority = .required, constant: CGFloat = 0) -> Self {
		return atLeast(value, priority: priority, multiplier: 0.5, constant: constant)
	}

	/// Makes the view at most the same dimension as another view. Convenience for `atLeast(.relative(view))`
	/// Note that the layout that is being referenced should already be in the same view hierarchy.
	public static func atLeast(sameAs view: UIView, priority: UILayoutPriority = .required, multiplier: CGFloat = 1, constant: CGFloat = 0) -> Self {
		return atLeast(.relative(view), priority: priority, multiplier: multiplier, constant: constant)
	}
	
	/// Makes the view exactly the same dimension as another view. Convenience for `exactly(.relative(view))`
	/// Note that the layout that is being referenced should already be in the same view hierarchy.
	public static func exactly(sameAs view: UIView, priority: UILayoutPriority = .required, multiplier: CGFloat = 1, constant: CGFloat = 0) -> Self {
		return exactly(.relative(view), priority: priority, multiplier: multiplier, constant: constant)
	}
	
	/// Makes the view at least the same dimension as another view. Convenience for `atMost(.relative(view))`
	/// Note that the layout that is being referenced should already be in the same view hierarchy.
	public static func atMost(sameAs view: UIView, priority: UILayoutPriority = .required, multiplier: CGFloat = 1, constant: CGFloat = 0) -> Self {
		return atMost(.relative(view), priority: priority, multiplier: multiplier, constant: constant)
	}
	
	/// Makes the view at least half of the dimension of another view. Convenience for `atLeast(halfOf: .relative(view))`
	/// Note that the layout that is being referenced should already be in the same view hierarchy.
	public static func atLeast(halfOf view: UIView, priority: UILayoutPriority = .required, constant: CGFloat = 0) -> Self {
		return atLeast(.relative(view), priority: priority, multiplier: 0.5, constant: constant)
	}
	
	/// Makes the view exactly half of the dimension of another view. Convenience for `exactly(halfOf: .relative(view))`
	/// Note that the layout that is being referenced should already be in the same view hierarchy.
	public static func exactly(halfOf view: UIView, priority: UILayoutPriority = .required, constant: CGFloat = 0) -> Self {
		return exactly(.relative(view), priority: priority, multiplier: 0.5, constant: constant)
	}
	
	/// Makes the view at most half of the dimension of another view. Convenience for `atMost(halfOf: .relative(view))`
	/// Note that the layout that is being referenced should already be in the same view hierarchy.
	public static func atMost(halfOf view: UIView, priority: UILayoutPriority = .required, constant: CGFloat = 0) -> Self {
		return atMost(.relative(view), priority: priority, multiplier: 0.5, constant: constant)
	}

	/// Makes the view at least `multiplier` multipliedBy  another layout.
	/// Note that the layout that is being referenced should already be in the same view hierarchy.
	public static func atLeast(_ value: T, multipliedBy multiplier: CGFloat, priority: UILayoutPriority = .required, constant: CGFloat = 0) -> Self {
		return atLeast(value, priority: priority, multiplier: multiplier, constant: constant)
	}

	/// Makes the view at least `multiplier` multipliedBy  another view.
	/// Note that the view that is being referenced should already be in the same view hierarchy.
	public static func atLeast(sameAs view: UIView, multipliedBy multiplier: CGFloat, priority: UILayoutPriority = .required, constant: CGFloat = 0) -> Self {
		return atLeast(.relative(view), priority: priority, multiplier: multiplier, constant: constant)
	}

	/// Makes the view exactly `multiplier` multipliedBy  another layout.
	/// Note that the layout that is being referenced should already be in the same view hierarchy.
	public static func exactly(_ value: T, multipliedBy multiplier: CGFloat, priority: UILayoutPriority = .required, constant: CGFloat = 0) -> Self {
		return exactly(value, priority: priority, multiplier: multiplier, constant: constant)
	}

	/// Makes the view exactly `multiplier` multipliedBy  another view.
	/// Note that the view that is being referenced should already be in the same view hierarchy.
	public static func exactly(sameAs view: UIView, multipliedBy multiplier: CGFloat, priority: UILayoutPriority = .required, constant: CGFloat = 0) -> Self {
		return exactly(.relative(view), priority: priority, multiplier: multiplier, constant: constant)
	}

	/// Makes the view at most `multiplier` multipliedBy  another layout.
	/// Note that the layout that is being referenced should already be in the same view hierarchy.
	public static func atMost(_ value: T, multipliedBy multiplier: CGFloat, priority: UILayoutPriority = .required, constant: CGFloat = 0) -> Self {
		return exactly(value, priority: priority, multiplier: multiplier, constant: constant)
	}

	/// Makes the view at most `multiplier` multipliedBy  another view.
	/// Note that the view that is being referenced should already be in the same view hierarchy.
	public static func atMost(sameAs view: UIView, multipliedBy multiplier: CGFloat, priority: UILayoutPriority = .required, constant: CGFloat = 0) -> Self {
		return exactly(.relative(view), priority: priority, multiplier: multiplier, constant: constant)
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
		], for: self)
		return self
	}
	
	/// Constrains this view `width` and `height` to a given `dimension`
	///
	/// - Parameters:
	///  - dimension: the dimension to constrain width and height to, one of .atLeast, .exactly, .atMost
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func constrain(widthAndHeight dimension: SizeConstrain<CGFloat>) -> Self {
		return constrain(width: dimension, height: dimension)
	}
	
	/// Constrains this view to a given `width` and `height`
	///
	/// - Parameters:
	///  - width: **optional** the constrained width, one of .atLeast, .exactly, .atMost
	///  - height: **optional** the constrained width, one of .atLeast, .exactly, .atMost
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func constrain(width: SizeConstrain<XAxisLayout>? = nil, height: SizeConstrain<YAxisLayout>? = nil) -> Self {
		ConstraintsList.activate([
			width.flatMap({ $0.layoutConstraint(for: widthAnchor, in: self)?.with(priority: $0.priority) }),
			height.flatMap({ $0.layoutConstraint(for: heightAnchor, in: self)?.with(priority: $0.priority) }),
		], for: self)
		return self
	}

	/// Constrains this view's `width` to a given `height` of another layout
	///
	/// - Parameters:
	///  - width: the constrained height to constrain the width of, one of .atLeast, .exactly, .atMost
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func constrain(widthAsHeightOf height: SizeConstrain<YAxisLayout>) -> Self {
		ConstraintsList.activate([
			height.layoutConstraint(for: widthAnchor, in: self)?.with(priority: height.priority),
		], for: self)
		return self
	}

	/// Constrains this view's `height` to a given `width` of another layout
	///
	/// - Parameters:
	///  - height: the constrained width to constrain the height of, one of .atLeast, .exactly, .atMost
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func constrain(heightAsWidthOf width: SizeConstrain<XAxisLayout>) -> Self {
		ConstraintsList.activate([
			width.layoutConstraint(for: heightAnchor, in: self)?.with(priority: width.priority),
		], for: self)
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
		
		ConstraintsList.activate(constraints, for: self)
		return self
	}
}


extension SizeConstrain where T == CGFloat {
	func layoutConstraint(for anchor: NSLayoutDimension) -> NSLayoutConstraint {
		let actualValue = value * multiplier + constant
		switch type {
			case .atLeast:
				return anchor.constraint(greaterThanOrEqualToConstant: actualValue)

			case .exactly:
				return anchor.constraint(equalToConstant: actualValue)

			case .atMost:
				return anchor.constraint(lessThanOrEqualToConstant: actualValue)
		}
	}
}

extension SizeConstrain where T: SingleAxisLayout {
	func layoutConstraint(for anchor: NSLayoutDimension, in view: UIView) -> NSLayoutConstraint? {
		guard let layoutAnchorsProvider = value.axis.layoutAnchorsProvider(in: view) else { return nil }
		let dimension = T.layoutDimension(in: layoutAnchorsProvider)
		
		switch type {
			case .atLeast:
				return anchor.constraint(greaterThanOrEqualTo: dimension, multiplier: multiplier, constant: constant)
				
			case .exactly:
				return anchor.constraint(equalTo: dimension, multiplier: multiplier, constant: constant)
				
			case .atMost:
				return anchor.constraint(lessThanOrEqualTo: dimension, multiplier: multiplier, constant: constant)
		}
	}
}
