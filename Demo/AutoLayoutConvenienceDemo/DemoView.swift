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
	}

	private func setup() {
		backgroundView.layer.cornerRadius = 16

		// create our content:
		//	- we stack the titles vertically, which will fill the horizontal axis
		//	- we center the stack vertically in the available space
		//	- and finally make the titles scroll vertically if needed
		//
		//	- the buttons are vertically stacked at the bottom, but will auto switch to a horizontal stack on vertical compact devices
		//subLabel.setContentCompressionResistancePriority(.required, for: .vertical)
		let content = UIView.verticallyStacked(
			UIView.verticallyStacked(titleLabel, subLabel, spacing: 4).verticallyCentered().verticallyScrollable(),
			UIView.autoAdjustingVerticallyStacked(actionButton, cancelButton, spacing: 8)
		)

		// Next up:
		// - we add our content to readable guide of the background, so our text never becomes too wide to read
		// - we make our background view fill up the available safeArea with a large inset to have some nice padding
		backgroundView.addSubview(content, filling: .readableContent)
		addSubview(backgroundView, filling: .safeArea, insets: .all(32))

		// And finally, we a close button to the top leading corner of our background view
		backgroundView.addSubview(closeButton.constrain(size: buttonSize), pinning: .center, to: .topLeading)
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
