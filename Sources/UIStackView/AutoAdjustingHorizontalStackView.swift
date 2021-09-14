//
//  AutoAdjustingHorizontalStackView.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 20/04/2021.
//

import UIKit

/// Horizontal StackView that automatically switches to a vertical
/// stackview when in accessibility mode
public class AutoAdjustingHorizontalStackView: AutoHidingStackView {

	// MARK: - Private
	private func updateForContentCategory() {
		if traitCollection.preferredContentSizeCategory.isAccessibilityCategory == true {
			axis = .vertical
		} else {
			axis = .horizontal
		}
	}

	// MARK: - UIView
	override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(traitCollection)
		updateForContentCategory()
	}

	override public init(frame: CGRect) {
		super.init(frame: frame)
		updateForContentCategory()
	}

	required public init(coder: NSCoder) {
		super.init(coder: coder)
		updateForContentCategory()
	}
}
