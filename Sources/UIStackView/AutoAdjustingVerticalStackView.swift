//
//  AutoAdjustingVerticalStackView.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 28/04/2021.
//

import UIKit

/// Vertical StackView that automatically switches to a horizontal
/// stackview when in compact mode
public class AutoAdjustingVerticalStackView: UIStackView {

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
