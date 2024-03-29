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
	public func wrapped(in layout: BoxLayout, preservesSuperviewLayoutMargins: Bool = true, insets: NSDirectionalEdgeInsets = Default.insets) -> UIView {
		let view = UIView()
		view.preservesSuperviewLayoutMargins = preservesSuperviewLayoutMargins
		view.addSubview(self, filling: layout, insets: insets)
		return view
	}
	
	/// Makes this view `preservesSuperviewLayoutMargins = true` and return self for chaining
	public func preservingSuperviewLayoutMargins() -> Self {
		preservesSuperviewLayoutMargins = true
		return self
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
	public convenience init(title: String? = nil, font: UIFont? = nil, type: UIButton.ButtonType) {
		self.init(type: type)
		self.setTitle(title, for: .normal)
		font.map { self.titleLabel?.font = $0 }
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
