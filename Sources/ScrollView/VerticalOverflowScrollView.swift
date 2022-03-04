//
//  VerticalOverflowScrollView.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 28/04/2021.
//

import UIKit

// this scrollview has an intrinsic content size, so it participates in (StackView) AutoLayout
// and it overflows content in the vertical direction
public class VerticalOverflowScrollView: UIScrollView {
	private var heightConstraint: NSLayoutConstraint!
	private var widthConstraint: NSLayoutConstraint!
	private var keyboardTracker = KeyboardTracker()
	private var keyboardTrackingCancellable: KeyboardTracker.Cancellable!

	/// if true, this scrollview will adjust the content inset to avoid the keyboard
	var isAdjustingForKeyboard = false {
		didSet {
			guard isAdjustingForKeyboard != oldValue else { return }
			updateInsetsForKeyboard()
		}
	}

	/// Adds a subview that overflows when needed or fills otherwise
	public func addOverflowingSubview(_ view: UIView, horizontally: HorizontalAxisLayout = .superview) {
		addSubview(view, filling: .horizontally(horizontally, vertically: .scrollContentOf(self)))
	}

	// MARK: - Private
	private func setup() {
		showsVerticalScrollIndicator = true
		showsHorizontalScrollIndicator = false

		contentInsetAdjustmentBehavior = .always
		alwaysBounceVertical = false
		alwaysBounceHorizontal = false

		heightConstraint = contentLayoutGuide.heightAnchor.constraint(greaterThanOrEqualTo: frameLayoutGuide.heightAnchor)
		widthConstraint = contentLayoutGuide.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor).with(priority: .required)
		NSLayoutConstraint.activate([heightConstraint, widthConstraint])

		keyboardTrackingCancellable = keyboardTracker.addObserver { [weak self] _ in
			guard self?.isAdjustingForKeyboard == true else { return }
			self?.updateInsetsForKeyboard()
		}
	}

	private func updateInternalConstraints() {
		super.updateConstraints()
		heightConstraint.constant = -(adjustedContentInset.top + adjustedContentInset.bottom)
		widthConstraint.constant = -(adjustedContentInset.left + adjustedContentInset.right)
	}

	private var effectiveContentInsets: UIEdgeInsets {
		guard isAdjustingForKeyboard == true else { return .zero }

		// we're only interested in vertical insets
		let boundsInScreenCoordinates = convert(bounds, to: nil)
		var keyboardScreenFrame = keyboardTracker.keyboardScreenFrame
		keyboardScreenFrame.origin.x = boundsInScreenCoordinates.minX
		keyboardScreenFrame.size.width = boundsInScreenCoordinates.width

		guard keyboardScreenFrame.isEmpty == false && keyboardScreenFrame.intersects(boundsInScreenCoordinates) == true else { return .zero }
		let keyboardHeightInView = max(boundsInScreenCoordinates.maxY - keyboardScreenFrame.minY, 0)
		return UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeightInView, right: 0)
	}

	private func updateInsetsForKeyboard(forceLayout: Bool = true) {
		let newBottomInset = max(effectiveContentInsets.bottom - safeAreaInsets.bottom, 0)
		guard newBottomInset != contentInset.bottom else { return }

		keyboardTracker.perform {
			self.contentInset.bottom = newBottomInset
			if #available(iOS 11.1, *) {
				self.verticalScrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: newBottomInset, right: 0)
			} else {
				self.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: newBottomInset, right: 0)
			}
			guard forceLayout == true else { return }
			self.setNeedsLayout()
			self.layoutIfNeeded()
		}
	}

	// MARK: - UIScrollView
	override public var contentSize: CGSize {
		didSet {
			guard contentSize != oldValue else { return }
			invalidateIntrinsicContentSize()
		}
	}

	public override func adjustedContentInsetDidChange() {
		super.adjustedContentInsetDidChange()
		updateInternalConstraints()
		invalidateIntrinsicContentSize()
	}

	// MARK: - UIView
	override public var intrinsicContentSize: CGSize {
		return contentSize
	}

	public override func safeAreaInsetsDidChange() {
		super.safeAreaInsetsDidChange()
		updateInsetsForKeyboard()
	}

	override public init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required public init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	public convenience init(with subview: UIView, horizontally: HorizontalAxisLayout = .superview, adjustsForKeyboard: Bool) {
		self.init()
		self.isAdjustingForKeyboard = adjustsForKeyboard
		addOverflowingSubview(subview, horizontally: horizontally)
		updateInsetsForKeyboard(forceLayout: false)
	}

	deinit {
		keyboardTrackingCancellable?.cancel()
	}
}
