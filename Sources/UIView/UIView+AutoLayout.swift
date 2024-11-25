//
//  UIView+AutoLayout.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 23/04/2021.
//

import UIKit

extension UIView {
	/// Adds a `subview` to `self` for use with **AutoLayout**
	/// and returns self for use in chaining calls
	///
	/// - Parameters:
	/// 	- subview the subview to add for use with **AutoLayout**
	///
	/// - Returns: `subview`, useful for chaining with contraint calls
	@discardableResult public func addSubviewForAutoLayout<ViewType: UIView>(_ subview: ViewType) -> ViewType {
		guard Self.ignoreSpuriousAddSubviewForAutoLayoutCount == 0 || subview.superview == nil else {
			assert(subview.superview == self, "You cannot add a subview conditionally to different views - the conditions only apply to the created constraints.")
			return subview
		}
		
		subview.translatesAutoresizingMaskIntoConstraints = false
		addSubview(subview)
		return subview
	}
}

extension UIView {
	static fileprivate var ignoreSpuriousAddSubviewForAutoLayoutCount = 0
	
	/// Used by conditional constraints, so that we can write multiple conditions with the same addSubview(subview, ...)
	/// but with different constraints. Since conditions are all executed once on creation, we want to only add the subview once
	/// and ignore the other ones while we are in a condition method. This method allows to do that.
	/// Note that adding the same subview to different superview is not supported and traps - we only conditionally apply the constraints.
	static internal func ignoreSpuriousAddSubviewForAutoLayoutCalls(during: () -> Void) {
		ignoreSpuriousAddSubviewForAutoLayoutCount += 1
		during()
		ignoreSpuriousAddSubviewForAutoLayoutCount -= 1
	}
}

extension UIView {
	/// Constraints the size of this view to constant values
	///
	/// - Parameters:
	/// 	- size: the size to constraint this view to
	/// 	- priority: **optional** the priority for the created constraints. defaults to `.required`
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func constrain(size: CGSize, priority: UILayoutPriority = .required) -> Self {
		return constrain(width: size.width, height: size.height)
	}

	/// Constraints the width and/or height of this view to constant values
	///
	/// - Parameters:
	/// 	- width: **optional** the width to constraint to, if set
	/// 	- height: **optional** the height to constraint to, if set
	/// 	- priority: **optional** the priority for the created constraints. defaults to `.required`
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func constrain(width: CGFloat? = nil, height: CGFloat? = nil, priority: UILayoutPriority = .required) -> Self {
		ConstraintsList.activate([
			height.flatMap({ heightAnchor.constraint(equalToConstant: $0).with(priority: priority) }),
			width.flatMap({ widthAnchor.constraint(equalToConstant: $0).with(priority: priority) }),
		], for: self)
		return self
	}
	
	/// Constraints the width and height of this view to a constant value
	///
	/// - Parameters:
	/// 	- value: **optional** the width tand height o constraint to,
	/// 	- priority: **optional** the priority for the created constraints. defaults to `.required`
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func constrain(widthAndHeight dimension: CGFloat, priority: UILayoutPriority = .required) -> Self {
		return constrain(width: dimension, height: dimension, priority: priority)
	}

	/// Constraints the aspect ratio of this view to aspect ratio of the given `size`
	///
	/// - Parameters:
	///		- size: the size of which to use the aspect ratio for constraining
	/// 	- priority: **optional** the priority for the created constraints. defaults to `.required`
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func constrainAspectRatio(for size: CGSize, priority: UILayoutPriority = .required) -> Self {
		return constrainAspectRatio(size.height != 0 ? size.width / size.height : 0)
	}

	/// Constraints the aspect ratio of this view to the given `ratio`, which
	/// should be expressed as width/height.
	///
	/// For example, if `ratio` = `0.5` the width will be half the height
	///
	/// - Parameters:
	///		- ratio: the width:height ratio to constraint to
	/// 	- priority: **optional** the priority for the created constraints. defaults to `.required`
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func constrainAspectRatio(_ ratio: CGFloat, priority: UILayoutPriority = .required) -> Self {
		ConstraintsList.activate([widthAnchor.constraint(equalTo: heightAnchor, multiplier: ratio).with(priority: priority)], for: self)
		return self
	}

	/// Removes any existing width or height constraint
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func removeSizeConstraints() -> Self {
		let constraintsToRemove = constraints.filter { $0.firstAttribute == .width || $0.firstAttribute == .height }
		NSLayoutConstraint.deactivate(constraintsToRemove)
		return self
	}

	/// Removes any existing width constraint
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func removeWidthConstraints() -> Self {
		let constraintsToRemove = constraints.filter { $0.firstAttribute == .width }
		NSLayoutConstraint.deactivate(constraintsToRemove)
		return self
	}

	/// Removes any existing height constraint
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func removeHeightConstraints() -> Self {
		let constraintsToRemove = constraints.filter { $0.firstAttribute == .height }
		NSLayoutConstraint.deactivate(constraintsToRemove)
		return self
	}
	
	/// Removes any existing constant width constraint
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func removeConstantWidthConstraints() -> Self {
		let constraintsToRemove = constraints.filter { $0.firstAttribute == .width && $0.secondItem == nil }
		NSLayoutConstraint.deactivate(constraintsToRemove)
		return self
	}
	
	/// Removes any existing constant height constraint
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func removeConstantHeightConstraints() -> Self {
		let constraintsToRemove = constraints.filter { $0.firstAttribute == .height && $0.secondItem == nil }
		NSLayoutConstraint.deactivate(constraintsToRemove)
		return self
	}
}

extension UIView {
	/// Allows this view to shrink vertically if needed
	///
	/// (sets `contentCompressionResistance` to `.defaultLow` for the vertical axis)
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public  func allowVerticalShrinking() -> Self {
		setContentCompressionResistancePriority(.defaultLow, for: .vertical)
		return self
	}

	/// Allows this view to shrink horizontally if needed
	///
	/// (sets `contentCompressionResistance` to `.defaultLow` for the horizontal axis)
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func allowHorizontalShrinking() -> Self {
		setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
		return self
	}

	/// Allows this view to shrink vertically and horizontally if needed
	///
	/// (sets `contentCompressionResistance` to `.defaultLow` for both axis)
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func allowShrinking() -> Self {
		return allowVerticalShrinking().allowHorizontalShrinking()
	}

	/// Disallows this view to shrink vertically if needed
	///
	/// (sets `contentCompressionResistance` to `.required` for the vertical axis)
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func disallowVerticalShrinking() -> Self {
		setContentCompressionResistancePriority(.required, for: .vertical)
		return self
	}

	/// Disllows this view to shrink horizontally if needed
	///
	/// (sets `contentCompressionResistance` to `.required` for the horizontal axis)
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func disallowHorizontalShrinking() -> Self {
		setContentCompressionResistancePriority(.required, for: .horizontal)
		return self
	}

	/// Allows this view to shrink vertically and horizontally if needed
	///
	/// (sets `contentCompressionResistance` to `.required` for both axis)
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func disallowShrinking() -> Self {
		return disallowVerticalShrinking().disallowHorizontalShrinking()
	}
}

extension UIView {
	/// Allows this view to grow vertically if needed
	///
	/// (sets `contentHuggingPriority` to `.defaultLow` for the vertical axis)
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func allowVerticalGrowing() -> Self {
		setContentHuggingPriority(.defaultLow, for: .vertical)
		return self
	}

	/// Allows this view to grow horizontally if needed
	///
	/// (sets `contentHuggingPriority` to `.defaultLow` for the horizontal axis)
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func allowHorizontalGrowing() -> Self {
		setContentHuggingPriority(.defaultLow, for: .horizontal)
		return self
	}

	/// Allows this view to grow vertically and horizontally if needed
	///
	/// (sets `contentHuggingPriority` to `.defaultLow` for the both axis)
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func allowGrowing() -> Self {
		return allowVerticalGrowing().allowHorizontalGrowing()
	}

	/// Disallows this view to grow vertically if needed
	///
	/// (sets `contentHuggingPriority` to `.required` for the vertical axis)
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func disallowVerticalGrowing() -> Self {
		setContentHuggingPriority(.required, for: .vertical)
		return self
	}

	/// Disallows this view to grow horizontally if needed
	///
	/// (sets `contentHuggingPriority` to `.required` for the horizontal axis)
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func disallowHorizontalGrowing() -> Self {
		setContentHuggingPriority(.required, for: .horizontal)
		return self
	}

	/// Disallows this view to grow vertically and horizontally if needed
	///
	/// (sets `contentHuggingPriority` to `.defaultLow` for the both axis)
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func disallowGrowing() -> Self {
		return disallowVerticalGrowing().disallowHorizontalGrowing()
	}
}

extension UIView {
	/// Prefers this view to not grow or shrink horizontally
	///
	/// (sets  `contentCompressionResistance` and ` contentHuggingPriority` to `.required` for the horizontal axis)
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func prefersExactHorizontalSize() -> Self {
		return disallowHorizontalGrowing().disallowHorizontalShrinking()
	}
	
	/// Prefers this view to not grow or shrink vertically
	///
	/// (sets  `contentCompressionResistance` and ` contentHuggingPriority` to `.required` for the vertical axis)
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func prefersExactVerticalSize() -> Self {
		return disallowVerticalGrowing().disallowVerticalShrinking()
	}
	
	/// Prefers this view to not grow or shrink
	///
	/// (sets  `contentCompressionResistance` and ` contentHuggingPriority` to `.required` for both axis)
	///
	/// - Returns: returns `self`, useful for chaining
	@discardableResult public func prefersExactSize() -> Self {
		return prefersExactHorizontalSize().prefersExactVerticalSize()
	}
}
