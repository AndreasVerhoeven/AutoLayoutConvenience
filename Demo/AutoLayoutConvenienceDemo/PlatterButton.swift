//
//  PlatterButton.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 28/04/2021.
//

import UIKit

// Helper method for buttons
extension UIButton {
	static func platter(title: String?, backgroundColor: UIColor? = nil, titleColor: UIColor? = nil) -> UIButton {
		let button = UIButton(title: title, type: .system)
		titleColor.map {button.setTitleColor($0, for: .normal) }
		button.backgroundColor = backgroundColor ?? .systemBlue
		button.layer.cornerRadius = 8
		return button.constrain(height: 50)
	}
}
