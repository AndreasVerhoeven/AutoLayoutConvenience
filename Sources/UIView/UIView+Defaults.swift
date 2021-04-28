//
//  UIView+Defaults.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 26/04/2021.
//

import UIKit

extension UIView {
	/// This hold the default markers for insets and spacing
	class Default {
		static let spacing = (CGFloat.greatestFiniteMagnitude - 1)
		static let insets = NSDirectionalEdgeInsets.all(CGFloat.greatestFiniteMagnitude - 1)
	}

	/// This calls a block wherein the defaults are temporarily overriden
	///
	/// - Parameters:
	///		- layoutAnchorable: **optional** the anchorable to use as a default
	///		- horizontally: **optional** the `ConstrainedHorizontalLayout` to use as a default
	///		- vertically: **optional** the `ConstrainedVerticalLayout` to use as a default
	///		- insets: **optional** the insets to use as a default
	///		- spacing: **optional** the spacing to use as default
	///		- callback: the block to execute wherein the defaults will be overriden with the given values
	static func with(_ layoutAnchorable: LayoutAnchorable = .default,
					 horizontally: ConstrainedHorizontalLayout = .default,
					 vertically: ConstrainedVerticalLayout = .default,
					 insets: NSDirectionalEdgeInsets = Default.insets,
					 spacing: CGFloat = Default.spacing,
					 callback: () -> Void) {
		Default.Resolved.with(layoutAnchorable, horizontally: horizontally, vertically: vertically, insets: insets, spacing: spacing, callback: callback)
	}

	/// This calls a block wherein the defaults are temporarily overriden.
	///
	/// - Parameters:
	///		- layoutAnchorable: **optional** the anchorable to use as a default
	///		- horizontally: **optional** the `ConstrainedHorizontalLayout` to use as a default
	///		- vertically: **optional** the `ConstrainedVerticalLayout` to use as a default
	///		- insets: **optional** the insets to use as a default
	///		- spacing: **optional** the spacing to use as default
	///		- callback: the block to execute wherein the defaults will be overriden with the given values
	func with(_ layoutAnchorable: LayoutAnchorable = .default,
			  horizontally: ConstrainedHorizontalLayout = .default,
			  vertically: ConstrainedVerticalLayout = .default,
			  insets: NSDirectionalEdgeInsets = Default.insets,
			  spacing: CGFloat = Default.spacing,
			  callback: () -> Void) {
		Self.with(layoutAnchorable, horizontally: horizontally, vertically: vertically, insets: insets, spacing: spacing, callback: callback)
	}
}

// MARK: - Resolving
extension UIView.Default {
	// Helper method to quicklt resolve spacing
	internal static func resolve(_ spacing: CGFloat) -> CGFloat {
		return spacing == self.spacing ? Resolved.spacing : spacing
	}

	// Helper method to quicklt resolve insets
	internal static func resolve(_ insets: NSDirectionalEdgeInsets) -> NSDirectionalEdgeInsets {
		return insets == self.insets ? Resolved.insets : insets
	}
}

extension UIView.Default {
	/// This holds the static data that are our custom defaults
	internal class Resolved {
		private static var layoutAnchorableStack = [LayoutAnchorable]()
		private static var insetsStack = [NSDirectionalEdgeInsets]()
		private static var spacingStack = [CGFloat]()
		private static var constrainedHorizontalLayoutStack = [ConstrainedHorizontalLayout]()
		private static var constrainedVerticalLayoutStack = [ConstrainedVerticalLayout]()
	}
}

extension UIView.Default.Resolved {
	/// This resolves defaults to their current value
	internal static var layoutAnchorable: LayoutAnchorable {  layoutAnchorableStack.last ?? .superview }
	internal static var insets: NSDirectionalEdgeInsets { insetsStack.last ?? .zero }
	internal static var spacing: CGFloat { spacingStack.last ?? 0 }
	internal static var constrainedHorizontalLayout: ConstrainedHorizontalLayout { constrainedHorizontalLayoutStack.last { $0.isDefault == false } ?? .fill }
	internal static var constrainedVerticalLayout: ConstrainedVerticalLayout { constrainedVerticalLayoutStack.last { $0.isDefault == false } ?? .fill }

	internal static var constrainedHorizontalLayoutIgnoringPassthru: ConstrainedHorizontalLayout { constrainedHorizontalLayoutStack.last { $0.isPassThru == false } ?? .fill }
	internal static var constrainedVerticalLayoutIgnoringPassthru: ConstrainedVerticalLayout { constrainedVerticalLayoutStack.last { $0.isPassThru == false } ?? .fill }

	// this executes the block with new defaults, pushing defaults on the stack only when necessary
	internal static func with(_ layoutAnchorable: LayoutAnchorable = .default,
						 horizontally: ConstrainedHorizontalLayout = .default,
						 vertically: ConstrainedVerticalLayout = .default,
						 insets: NSDirectionalEdgeInsets = UIView.Default.insets,
						 spacing: CGFloat = UIView.Default.spacing,
						 callback: () -> Void) {
		if layoutAnchorable.isDefault == false {
			layoutAnchorableStack.append(layoutAnchorable)
		}

		if horizontally.isDefault != false || horizontally.constrained != false {
			constrainedHorizontalLayoutStack.append(horizontally)
		}


		if vertically.isDefault != false || vertically.constrained != false {
			constrainedVerticalLayoutStack.append(vertically)
		}

		if insets != UIView.Default.insets {
			insetsStack.append(insets)
		}


		if spacing != UIView.Default.spacing {
			spacingStack.append(spacing)
		}

		callback()

		if spacing != UIView.Default.spacing {
			spacingStack.removeLast()
		}

		if insets != UIView.Default.insets {
			insetsStack.removeLast()
		}

		if vertically.isDefault != false || vertically.constrained != false {
			constrainedVerticalLayoutStack.removeLast()
		}

		if horizontally.isDefault != false || horizontally.constrained != false {
			constrainedHorizontalLayoutStack.removeLast()
		}

		if layoutAnchorable.isDefault == false {
			layoutAnchorableStack.removeLast()
		}
	}
}

