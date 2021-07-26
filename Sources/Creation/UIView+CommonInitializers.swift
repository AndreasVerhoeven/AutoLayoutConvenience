//
//  UIView+CommonInitializers.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 24/04/2021.
//

import UIKit

extension UIView {
	public convenience init(backgroundColor: UIColor, alpha: CGFloat = 1) {
		self.init()
		self.backgroundColor = backgroundColor
		self.alpha = alpha
	}


	/// Return this view wrapped in another view with the given layout
	public func wrapped(in layout: BoxLayout) -> UIView {
		let view = UIView()
		view.addSubview(self, filling: layout)
		return view
	}
}

extension UILabel {
	public convenience init(text: String? = nil, font: UIFont, color: UIColor? = nil, alignment: NSTextAlignment = .natural, numberOfLines: Int = 0) {
		self.init()
		self.text = text
		self.font = font
		self.adjustsFontForContentSizeCategory = true
		self.textAlignment = alignment
		color.map { self.textColor = $0}
		self.numberOfLines = numberOfLines
	}

	public convenience init(text: String? = nil, textStyle: UIFont.TextStyle = .body, color: UIColor? = nil, alignment: NSTextAlignment = .natural, numberOfLines: Int = 0) {
		self.init()
		self.text = text
		self.font = UIFont.preferredFont(forTextStyle: textStyle)
		self.adjustsFontForContentSizeCategory = true
		self.textAlignment = alignment
		color.map { self.textColor = $0}
		self.numberOfLines = numberOfLines
	}
}

extension UITextView {
	public convenience init(text: String? = nil, font: UIFont, color: UIColor? = nil, alignment: NSTextAlignment = .natural, isScrollEnabled: Bool = false) {
		self.init()
		self.text = text
		self.font = font
		self.textAlignment = alignment
		self.adjustsFontForContentSizeCategory = true
		color.map { self.textColor = $0}
		self.isScrollEnabled = isScrollEnabled
	}

	public convenience init(text: String? = nil, textStyle: UIFont.TextStyle = .body, color: UIColor? = nil, alignment: NSTextAlignment = .natural, isScrollEnabled: Bool = false) {
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
	public convenience init(title: String? = nil, type: UIButton.ButtonType) {
		self.init(type: type)
		self.setTitle(title, for: .normal)
		self.titleLabel?.adjustsFontForContentSizeCategory = true
		adjustsImageSizeForAccessibilityContentSizeCategory = true
	}
}

extension UIImageView {
	public convenience init(image: UIImage? = nil, contentMode: UIView.ContentMode) {
		self.init(image: image)
		self.contentMode = contentMode
	}
}
