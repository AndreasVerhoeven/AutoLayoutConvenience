//
//  AutoHidingStackView.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 14/09/2021.
//

import UIKit

/// A UIStackView subclass that sets `isHidden = true` when there are
/// no visible, non hidden sub views and `isHidden = false` when there
/// is at least one non hidden sub view, if
/// `automaticallyHidesWhenNotHavingVisibleSubviews` is `true.`
@objcMembers public class AutoHidingStackView: UIStackView {
	/// default value for `automaticallyHidesWhenNotHavingVisibleSubviews`
	public static var defaultAutomaticallyHidesWhenNotHavingVisibleSubviews = false

	/// Determines whether to hide automatically when there are no visible subviews
	public var automaticallyHidesWhenNotHavingVisibleSubviews = AutoHidingStackView.defaultAutomaticallyHidesWhenNotHavingVisibleSubviews {
		didSet {
			guard automaticallyHidesWhenNotHavingVisibleSubviews != oldValue else { return }
			setNeedsUpdateConstraints()
		}
	}

	// MARK: - UIView
	public override func setNeedsUpdateConstraints() {
		super.setNeedsUpdateConstraints()
		guard automaticallyHidesWhenNotHavingVisibleSubviews == true else { return }
		let needsToBeHidden = (arrangedSubviews.contains { $0.isHidden == false } == false)
		guard isHidden != needsToBeHidden else { return }
		isHidden = needsToBeHidden
	}
}
