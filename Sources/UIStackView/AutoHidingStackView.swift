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
@objcMembers open class AutoHidingStackView: UIStackView {
	/// default value for `automaticallyHidesWhenNotHavingVisibleSubviews`
	public static var defaultAutomaticallyHidesWhenNotHavingVisibleSubviews = true

	/// Determines whether to hide automatically when there are no visible subviews
	public var automaticallyHidesWhenNotHavingVisibleSubviews = AutoHidingStackView.defaultAutomaticallyHidesWhenNotHavingVisibleSubviews {
		didSet {
			guard automaticallyHidesWhenNotHavingVisibleSubviews != oldValue else { return }
			setNeedsUpdateConstraints()
		}
	}

	// MARK: - Privates

	/// WORKAROUND When UIStackView has a single view and we switch between center and any other alignment, the layout breaks
	/// because UIStackView forgets to remove the constraints for centering the view. We need to force the stack view to remove the constraint
	/// by temporarily inserting another hidden subview, this makes UIStackView do the right thing. Sad, but necessary.
	private var applyCenterConstraintWrongWorkaround = false
	private var centerConstraintWorkAroundSubview: UIView?
	private final class WorkAroundForSingleViewSwitchingBetweenCenterAndOtherAlignmentBreakingLayout: UIView {
	}

	// MARK: - UIStackView

	open override var alignment: UIStackView.Alignment {
		didSet {
			guard alignment != oldValue else { return }

			if subviews.count == 1 && (oldValue == .center || alignment == .center) {
				applyCenterConstraintWrongWorkaround = true
			}

		}
	}

	open override func layoutSubviews() {
		/// Remove our workaround view
		if let centerConstraintWorkAroundSubview {
			removeArrangedSubview(centerConstraintWorkAroundSubview)
			centerConstraintWorkAroundSubview.removeFromSuperview()
			self.centerConstraintWorkAroundSubview = nil
		}

		super.layoutSubviews()
	}

	open override func updateConstraints() {
		/// Because UIStackView breaks layout when we have a single view and coming from a center layout,
		/// we'll add a hidden view temporary __before__ the UIStackView updates it constraints. This somehow forces
		/// UIStackView to do the right thing with the constraints and delete the center constrain correctly.
		///
		/// We cannot remove the view after calling `super.updateConstraints()`, because that
		/// will make our constraints dirty again which is not allowed in `updateConstraints()`.
		/// So, we remove it inside `layoutSubviews()`, which get called directly
		/// __after__ `updateConstraints()`
		if applyCenterConstraintWrongWorkaround == true,
		   centerConstraintWorkAroundSubview == nil {
			applyCenterConstraintWrongWorkaround = false

			let workaroundView = WorkAroundForSingleViewSwitchingBetweenCenterAndOtherAlignmentBreakingLayout()
			workaroundView.isHidden = true
			centerConstraintWorkAroundSubview = workaroundView
			addArrangedSubview(workaroundView)
		}

		super.updateConstraints()
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
