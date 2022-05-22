//
//  DemoView.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 28/04/2021.
//

import UIKit

class DemoView: UIView {
	// Initialize some subviews
	let titleLabel = UILabel(text: "Title Label", textStyle: .largeTitle, alignment: .center)
	let subLabel = UILabel(text: String(repeating: "Sub label with a lot of text. ", count: 10), textStyle: .body, alignment: .center)
	let closeButton = UIButton(type: .close)
	let backgroundView = UIView(backgroundColor: .systemGroupedBackground)
	let actionButton = UIButton.platter(title: "Add More Text", titleColor: .white)
	let cancelButton = UIButton.platter(title: "Revert", backgroundColor: .white)
	let buttonSize = CGSize(width: 32, height: 32)
	let smallButtonSize = CGSize(width: 24, height: 24)
	let textField = UITextField(backgroundColor: .tertiarySystemBackground).constrain(heightBetween: 32..<40)

	// Helper method to animate sub title changes
	func setSubTitleAnimated(_ text: String) {
		subLabel.contentMode = .top // needed for nicer animations
		layoutIfNeeded()
		UIView.animate(withDuration: 0.25) {
			UIView.transition(with: self.subLabel, duration: 0.25, options: [.beginFromCurrentState, .transitionCrossDissolve]) {
				self.subLabel.text = text
			}
			self.layoutIfNeeded()
		}
		firstScrollableView?.flashScrollIndicators()
	}

	private func setup() {
		backgroundView.layer.cornerRadius = 16
		textField.returnKeyType = .done
		textField.placeholder = "Bring up the keyboard"
		textField.layer.cornerRadius = 8
		textField.leftView = UIView().constrain(width: 16)
		textField.leftViewMode = .always

		// create our content:
		//	- we stack the titles vertically, which will fill the horizontal axis
		//	- we center the stack vertically in the available space
		//	- and finally make the titles scroll vertically if needed
		//
		//	- the buttons are vertically stacked at the bottom, but will auto switch to a horizontal stack on vertical compact devices
		let content = UIView.verticallyStacked(
			UIView.verticallyStacked(titleLabel, subLabel, spacing: 4, insets: .all(16)).verticallyCentered().verticallyScrollable(),
			UIView.autoAdjustingVerticallyStacked(textField, actionButton, cancelButton, spacing: 8)
		)

		// Next up:
		// - we add our content to readable guide of the background, so our text never becomes too wide to read
		// - we make our background view fill up the available safeArea with a large inset to have some nice padding
		backgroundView.addSubview(content, filling: .readableContent)
		addSubview(backgroundView, filling: .safeArea, insets: .all(32))

		// And finally, we a close button to the top leading corner of our background view, conditionally:
		UIView.if(.verticallyCompact) {
			// if we're vertically
			backgroundView.addSubview(closeButton.constrain(size: smallButtonSize), pinning: .center, to: .topTrailing)
		} else: {
			backgroundView.addSubview(closeButton.constrain(size: buttonSize), pinning: .center, to: .topLeading)
		}
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
}
