//
//  AutoAdjustingHorizontalStackView.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 20/04/2021.
//

import UIKit

class AutoAdjustingHorizontalStackView: UIStackView {

	// MARK: - Private
	private func updateForContentCategory() {
		if traitCollection.preferredContentSizeCategory.isAccessibilityCategory == true {
			axis = .vertical
		} else {
			axis = .horizontal
		}
	}

	// MARK: - UIView
	override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(traitCollection)
		updateForContentCategory()
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		updateForContentCategory()
	}

	required init(coder: NSCoder) {
		super.init(coder: coder)
		updateForContentCategory()
	}
}
