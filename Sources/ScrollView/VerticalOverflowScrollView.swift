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

	// MARK: - Private
	private func setup() {
		showsVerticalScrollIndicator = true
		showsHorizontalScrollIndicator = false

		alwaysBounceVertical = false
		alwaysBounceHorizontal = false

		NSLayoutConstraint.activate([
			contentLayoutGuide.heightAnchor.constraint(greaterThanOrEqualTo: frameLayoutGuide.heightAnchor),
			contentLayoutGuide.widthAnchor.constraint(equalTo: frameLayoutGuide.widthAnchor).with(priority: .required),
		])
	}

	func addOverflowingSubview(_ view: UIView, horizontally: HorizontalAxisLayout = .superview) {
		addSubview(view, filling: .horizontally(horizontally, vertically: .scrollContentOf(self)))
	}

	// MARK: - UIScrollView
	override public var contentSize: CGSize {
		didSet {
			guard contentSize != oldValue else { return }
			invalidateIntrinsicContentSize()
		}
	}

	// MARK: - UIView
	override public var intrinsicContentSize: CGSize {
		return contentSize
	}

	override public init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required public init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	public convenience init(with subview: UIView, horizontally: HorizontalAxisLayout = .superview) {
		self.init()
		addOverflowingSubview(subview, horizontally: horizontally)
	}
}
