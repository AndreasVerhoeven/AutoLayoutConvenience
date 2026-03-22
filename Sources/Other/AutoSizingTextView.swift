//
//  AutoSizingTextView.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 09/08/2021.
//

import UIKit

/// A UITextView subclass that auto sizes itself with AutoLayout
/// to fit the text.
open class AutoSizingTextView: UITextView {

	/// limits the height of the textView
	open var maximumHeight = CGFloat(0.0) {
		didSet {
			guard maximumHeight != oldValue else { return }
			updateScrollEnabledIfNeeded()
		}
	}

	/// will be called when the content size is invalidated
	open var contentSizeInvalidatedCallback: ContentSizeCallback?
	public typealias ContentSizeCallback = (AutoSizingTextView) -> Void

	/// place holder for this text view
	open var placeholder: String? {
		get { placeholderTextView.text }
		set { placeholderTextView.text = newValue }
	}

	private var ignoreBoundsChanges = false
	private var hasUpdatedScrollIsEnabled = false
	private let placeholderTextView = UITextView()

	// MARK: - Privates
	@objc private func textDidChange(_ note: Notification) {
		// needed incase isScrollEnabled is set to true which stops automatically calling invalidateIntrinsicContentSize()
		invalidateIntrinsicContentSize()
		placeholderTextView.isHidden = !text.isEmpty
		updateScrollEnabledIfNeeded()
	}

	private func scrollToCaret(animated: Bool) {
		guard let selectedTextRange = selectedTextRange else {return}
		var caret = caretRect(for: selectedTextRange.start)
		caret.size.height += textContainerInset.bottom
		scrollRectToVisible(caret, animated: animated)
	}

	private func updateScrollEnabledIfNeeded() {
		ignoreBoundsChanges = true

		layoutManager.glyphRange(for: textContainer)
		let oldIsScrollEnabled = isScrollEnabled
		super.isScrollEnabled = true
		let textHeight = layoutManager.usedRect(for: textContainer).height + textContainerInset.top + textContainerInset.bottom

		if textHeight != bounds.height {
			self.contentSizeInvalidatedCallback?(self)
		}

		isScrollEnabled = (bounds.height < textHeight)
		if isScrollEnabled != oldIsScrollEnabled, isScrollEnabled == true {
			scrollToCaret(animated: false)
			if hasUpdatedScrollIsEnabled == true {
				flashScrollIndicators()
			}
		}
		hasUpdatedScrollIsEnabled = true
		ignoreBoundsChanges = false
	}

	private func setup() {
		isScrollEnabled = false
		autoresizingMask = [.flexibleWidth, .flexibleHeight]
		NotificationCenter.default.addObserver(self, selector: #selector(UITextInputDelegate.textDidChange(_:)), name: UITextView.textDidChangeNotification, object: self)

		placeholderTextView.backgroundColor = .clear
		placeholderTextView.isScrollEnabled = false
		if #available(iOS 13, *) {
			placeholderTextView.textColor = .placeholderText
		} else {
			placeholderTextView.textColor = .lightGray
		}
		placeholderTextView.isUserInteractionEnabled = false
		placeholderTextView.font = font
		placeholderTextView.isAccessibilityElement = false
		addSubview(placeholderTextView, filling: .superview)
	}

	// MARK: - UITextView
	public override init(frame: CGRect, textContainer: NSTextContainer?) {
		super.init(frame: frame, textContainer: textContainer)
		setup()
	}

	public required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
		setup()
	}

	open override var text: String! {
		didSet {
			invalidateIntrinsicContentSize()
			placeholderTextView.isHidden = !text.isEmpty
		}
	}

	open override var font: UIFont? {
		didSet {
			placeholderTextView.font = font
			invalidateIntrinsicContentSize()
		}
	}

	open override var contentInset: UIEdgeInsets {
		didSet {
			placeholderTextView.contentInset = contentInset
		}
	}

	open override var textContainerInset: UIEdgeInsets {
		didSet {
			placeholderTextView.textContainerInset = textContainerInset
			invalidateIntrinsicContentSize()
		}
	}

	open override var adjustsFontForContentSizeCategory: Bool {
		didSet {
			placeholderTextView.adjustsFontForContentSizeCategory = adjustsFontForContentSizeCategory
		}
	}

	open override var bounds: CGRect {
		didSet {
			guard ignoreBoundsChanges == false else {return}
			updateScrollEnabledIfNeeded()
		}
	}

	open override var intrinsicContentSize: CGSize {
		var size = super.intrinsicContentSize

		if size.height == UIView.noIntrinsicMetric {
			layoutManager.glyphRange(for: textContainer)
			size.height = layoutManager.usedRect(for: textContainer).height + textContainerInset.top + textContainerInset.bottom
		}

		if maximumHeight > 0.0 && size.height > maximumHeight {
			size.height = maximumHeight

			if isScrollEnabled == false {
				isScrollEnabled = true
			}
		} else if isScrollEnabled == true {
			isScrollEnabled = false
		}

		return size
	}

	// MARK: - NSObject
	open override var accessibilityLabel: String? {
		get {return text.isEmpty == true ? placeholder : super.accessibilityLabel}
		set {super.accessibilityLabel = newValue}
	}
}

public extension AutoSizingTextView {
	/// Creates an AutoSizingTextView with a placeholder, optional font and an optional backgroundColor
	convenience init(placeholder: String?, font: UIFont? = nil, backgroundColor: UIColor = .clear) {
		self.init(frame: .zero)
		self.placeholder = placeholder
		self.backgroundColor = backgroundColor
		if let font = font {
			self.font = font
			self.placeholderTextView.font = font
		}
	}
}
