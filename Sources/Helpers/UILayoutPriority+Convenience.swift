//
//  UILayoutPriority+Convenience.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 23/04/2021.
//

import UIKit

public extension UILayoutPriority {
	// WORKAROUND (iOS 11, *) UIStackView adds a 50% width constraint with priority 759 or 760
	//                        for labels.
	static var stackViewWorkaroundHigh = UILayoutPriority(rawValue: 761)

	// WORKAROUND (iOS 11, *) self sizing cells needs a height constraint of 999
	static var selfSizingCellHeightWorkaround = UILayoutPriority(rawValue: 999)

	/// One higher that the current priority
	var higher: UILayoutPriority {
		return higher(1)
	}

	/// One lower that the current priority
	var lower: UILayoutPriority {
		return lower(1)
	}

	/// Higger than the current priority
	///
	/// - Parameters:
	/// 	- value: the value by which to increase the current priority
	///
	/// - Returns: A layout priority that is higher by `value` than the current priority
	func higher(_ value: Float) -> UILayoutPriority {
		return offsetted(value)
	}

	/// Lower than the current priority
	///
	/// - Parameters:
	/// 	- value: the value by which to decrease the current priority
	///
	/// - Returns: A layout priority that is lower by `value` than the current priority
	func lower(_ value: Float) -> UILayoutPriority {
		return offsetted(-value)
	}

	/// Layout priority offsetted
	///
	/// - Parameters:
	/// 	- value: the value by which to offset the current priority
	///
	/// - Returns: A layout priority that offsetted the current priority by `value`
	func offsetted(_ offset: Float) -> UILayoutPriority {
		return UILayoutPriority(rawValue: rawValue + offset)
	}

	/// Layout priority offsetted
	///
	/// - Parameters:
	/// 	- priority: the priority to offset
	/// 	- value: the value by which to offset the current priority
	///
	/// - Returns: A layout priority that offsetted the current priority by `value`
	static func offsetted(_ priority: UILayoutPriority, offset: Float) -> UILayoutPriority {
		return priority.offsetted(offset)
	}
}
