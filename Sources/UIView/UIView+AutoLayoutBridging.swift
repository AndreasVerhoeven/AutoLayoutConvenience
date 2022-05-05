//
//  UIView+AutoLayoutBridging.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 04/05/2022.
//

import UIKit

/// This view bridges a manual layout view to AutoLayout. The manual layout view must implement
/// sizeThatFits() and can use invalidateIntrinsicContentSize() to notify about changes. This bridging view,
/// in turn, will have an intrinsicContentSize based on sizeThatFits.
public class ManualLayoutInAutoLayoutBridgingView: UIView {
	/// the manual layout view we are bridging to auto layout
	public let view: UIView
	
	/// this is the axis that we cannot grow on. The other axis is seen as unbounded
	/// when we call sizeThatFits()
	public var constrainedOnAxis: NSLayoutConstraint.Axis {
		didSet {
			guard constrainedOnAxis != oldValue else { return }
			updateStackViewAxis()
			invalidateIntrinsicContentSize()
		}
	}
	
	/// Creates an AutoLayoutBridgingView that bridges the manual layout `view` to auto layout
	public init(view: UIView, constrained axis: NSLayoutConstraint.Axis = .horizontal) {
		self.view = view
		self.constrainedOnAxis = axis
		super.init(frame: .zero)
		
		updateStackViewAxis()
		stackView.callback = { self.layoutSubviews() }
		stackView.addArrangedSubviews(view)
		addSubview(stackView, filling: .superview)
	}
	
	@available(*, unavailable)
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	/// make the view updates is size
	public func update() {
		invalidateIntrinsicContentSize()
		if isHidden != view.isHidden {
			isHidden = view.isHidden
		}
	}
	
	// MARK: - Privates
	private let stackView = CallbackStackView(axis: .vertical, alignment: .fill, distribution: .fillProportionally)
	private class CallbackStackView: UIStackView {
		var callback: (() -> Void)?
		override func updateConstraints() {
			super.updateConstraints()
			callback?()
		}
	}
	
	private func updateStackViewAxis() {
		switch constrainedOnAxis {
			case .vertical: stackView.axis = .horizontal
			case .horizontal: stackView.axis = .vertical
			@unknown default: stackView.axis = .horizontal
		}
	}
	
	// MARK: - UIView
	public override func sizeThatFits(_ size: CGSize) -> CGSize {
		return view.sizeThatFits(size)
	}
	
	public override var intrinsicContentSize: CGSize {
		switch constrainedOnAxis {
			case .vertical:
				return sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: bounds.height))
				
			case .horizontal:
				fallthrough
			@unknown default:
				return sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
		}
	}
	
	public override func layoutSubviews() {
		super.layoutSubviews()
		update()
	}
}
