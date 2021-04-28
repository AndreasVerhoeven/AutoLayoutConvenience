//
//  AutoAdjustingVerticalStackView.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 28/04/2021.
//

import UIKit

// Vertical StackView that automatically switches to a horizontal
// stackview when in compact mode

class AutoAdjustingVerticalStackView: UIStackView {

	// MARK: - Private
	private func updateForContentCategory() {
		switch traitCollection.verticalSizeClass {
			case .compact:
				axis = .horizontal
				distribution = .fillEqually

			case .unspecified, .regular:
				fallthrough
			@unknown default:
				axis = .vertical
				distribution = .fill
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


extension UIView {
	static func autoAdjustingVerticallyStacked(_ views: UIView..., spacing: CGFloat = 0, insets: NSDirectionalEdgeInsets? = .zero) -> UIStackView {
		return autoAdjustingVerticallyStacked(views, spacing: spacing, insets: insets)
	}

	static func autoAdjustingVerticallyStacked(_ views: [UIView], spacing: CGFloat = 0, insets: NSDirectionalEdgeInsets? = .zero) -> UIStackView {
		return AutoAdjustingVerticalStackView(with: views, spacing: spacing, insets: insets)
	}
}
