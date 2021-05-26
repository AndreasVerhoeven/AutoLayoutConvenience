//
//  NSDirectionalEdgeInsets+Convenience.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 21/04/2021.
//  Copyright © 2021 bunq. All rights reserved.
//

import UIKit


public extension NSDirectionalEdgeInsets {

	// MARK: - Initializers
	static func top(_ top: CGFloat) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: top, leading: 0, bottom: 0, trailing: 0)
	}

	static func leading(_ leading: CGFloat) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 0, leading: leading, bottom: 0, trailing: 0)
	}

	static func trailing(_ trailing: CGFloat) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: trailing)
	}

	static func bottom(_ bottom: CGFloat) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: bottom, trailing: 0)
	}

	// MARK: - Modifiers
	func with(top: CGFloat) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
	}

	func with(leading: CGFloat) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
	}

	func with(bottom: CGFloat) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
	}

	func with(trailing: CGFloat) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: top, leading: leading, bottom: bottom, trailing: trailing)
	}

	func with(horizontal: CGFloat) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: top, leading: horizontal, bottom: bottom, trailing: horizontal)
	}
	func with(vertical: CGFloat) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: vertical, leading: leading, bottom: vertical, trailing: trailing)
	}

	// MARK: - Inverter
	func inverted() -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: -top, leading: -leading, bottom: -bottom, trailing: -trailing)
	}

	// MARK: - Math
	func adding(_ other : NSDirectionalEdgeInsets) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: top + other.top, leading: leading + other.leading, bottom: bottom + other.bottom, trailing: trailing + other.trailing)
	}

	func multiply(by factor: CGFloat) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: top * factor, leading: leading * factor, bottom: bottom * factor, trailing: trailing * factor)
	}

	// MARK: - Insets
	static func insets(horizontal: CGFloat = 0, vertical: CGFloat = 0) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
	}

	static func inset(_ value: CGFloat) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: value, leading: value, bottom: value, trailing: value)
	}

	static func horizontal(_ inset: CGFloat) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: 0, leading: inset, bottom: 0, trailing: inset)
	}

	static func vertical(_ inset: CGFloat) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: inset, leading: 0, bottom: inset, trailing: 0)
	}

	static func horizontally(_ horizontal: CGFloat, vertically vertical: CGFloat) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
	}

	static func all(_ value: CGFloat) -> NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: value, leading: value, bottom: value, trailing: value)
	}

	// MARK: - Concatenating

	static func with(_ insets: NSDirectionalEdgeInsets...) -> NSDirectionalEdgeInsets {
		return insets.reduce(NSDirectionalEdgeInsets.zero, {$0.adding($1)})
	}

	// MARK: - Weird Helpers
	var horizontallySwapped: NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: top, leading: trailing, bottom: bottom, trailing: leading)
	}

	var verticallySwapped: NSDirectionalEdgeInsets {
		return NSDirectionalEdgeInsets(top: bottom, leading: leading, bottom: top, trailing: trailing)
	}

	// MARK: - Converting
	var edgeInsets: UIEdgeInsets {
		return UIEdgeInsets(top: top, left: leading, bottom: bottom, right: trailing)
	}

	var horizontalInset: CGFloat {
		return leading + trailing
	}

	var verticalInset: CGFloat {
		return top + bottom
	}
}


