//
//  HorizontalOverflowScrollView.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 28/04/2021.
//

import UIKit

// this scrollview has an intrinsic content size, so it participates in (StackView) AutoLayout
// and it overflows content in the horizontal direction
public class HorizontalOverflowScrollView: UIScrollView {

	// MARK: - Private
	private func setup() {
		showsVerticalScrollIndicator = false
		showsHorizontalScrollIndicator = true

		alwaysBounceVertical = false
		alwaysBounceHorizontal = false

		NSLayoutConstraint.activate([
			contentLayoutGuide.widthAnchor.constraint(greaterThanOrEqualTo: frameLayoutGuide.widthAnchor),
			contentLayoutGuide.heightAnchor.constraint(equalTo: frameLayoutGuide.heightAnchor).with(priority: .required),
		])
	}

	public func addOverflowingSubview(_ view: UIView, vertically: VerticalAxisLayout = .superview) {
		addSubview(view, filling: .horizontally(.scrollContentOf(self), vertically: vertically))
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

	public convenience init(with subview: UIView, vertically: VerticalAxisLayout = .superview) {
		self.init()
		addOverflowingSubview(subview, vertically: vertically)
	}
}
