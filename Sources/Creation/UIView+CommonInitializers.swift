//
//  UIView+CommonInitializers.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 24/04/2021.
//

import UIKit

extension UIView {
	convenience init(backgroundColor: UIColor, alpha: CGFloat = 1) {
		self.init()
		self.backgroundColor = backgroundColor
		self.alpha = alpha
	}
}

extension UILabel {
	convenience init(text: String? = nil, font: UIFont, color: UIColor? = nil, alignment: NSTextAlignment = .natural, numberOfLines: Int = 0) {
		self.init()
		self.text = text
		self.font = font
		self.adjustsFontForContentSizeCategory = true
		self.textAlignment = alignment
		color.map { self.textColor = $0}
		self.numberOfLines = 0
	}

	convenience init(text: String? = nil, textStyle: UIFont.TextStyle = .body, color: UIColor? = nil, alignment: NSTextAlignment = .natural, numberOfLines: Int = 0) {
		self.init()
		self.text = text
		self.font = UIFont.preferredFont(forTextStyle: textStyle)
		self.adjustsFontForContentSizeCategory = true
		self.textAlignment = alignment
		color.map { self.textColor = $0}
		self.numberOfLines = 0
	}
}

extension UITextView {
	convenience init(text: String? = nil, font: UIFont, color: UIColor? = nil, alignment: NSTextAlignment = .natural, isScrollEnabled: Bool = false) {
		self.init()
		self.text = text
		self.font = font
		self.textAlignment = alignment
		self.adjustsFontForContentSizeCategory = true
		color.map { self.textColor = $0}
		self.isScrollEnabled = isScrollEnabled
	}

	convenience init(text: String? = nil, textStyle: UIFont.TextStyle = .body, color: UIColor? = nil, alignment: NSTextAlignment = .natural, isScrollEnabled: Bool = false) {
		self.init()
		self.text = text
		self.font = UIFont.preferredFont(forTextStyle: textStyle)
		self.textAlignment = alignment
		self.adjustsFontForContentSizeCategory = true
		color.map { self.textColor = $0}
		self.isScrollEnabled = isScrollEnabled
	}
}

extension UIButton {
	convenience init(title: String? = nil, type: UIButton.ButtonType) {
		self.init(type: type)
		self.setTitle(title, for: .normal)
		self.titleLabel?.adjustsFontForContentSizeCategory = true
		adjustsImageSizeForAccessibilityContentSizeCategory = true
	}
}

extension UIImageView {
	convenience init(image: UIImage? = nil, contentMode: UIView.ContentMode) {
		self.init(image: image)
		self.contentMode = contentMode
	}
}
