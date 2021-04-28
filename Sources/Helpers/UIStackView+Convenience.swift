//
//  UIStackView+Convenience.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 23/04/2021.
//

import UIKit

extension UIStackView {

	convenience init(with views: UIView...,
					 axis: NSLayoutConstraint.Axis = .vertical,
					 alignment: UIStackView.Alignment = .fill,
					 distribution: UIStackView.Distribution = .fill,
					 spacing: CGFloat = 0,
					 insets: NSDirectionalEdgeInsets? = nil) {
		self.init()
		setup(with: views, axis: axis, alignment: alignment, distribution: distribution, spacing: spacing, insets: insets)
	}

	convenience init(with views: [UIView] = [],
					 axis: NSLayoutConstraint.Axis = .vertical,
					 alignment: UIStackView.Alignment = .fill,
					 distribution: UIStackView.Distribution = .fill,
					 spacing: CGFloat = 0,
					 insets: NSDirectionalEdgeInsets? = nil) {
		self.init()
		setup(with: views, axis: axis, alignment: alignment, distribution: distribution, spacing: spacing, insets: insets)
	}

	private func setup(with views: [UIView],
					   axis: NSLayoutConstraint.Axis,
					   alignment: UIStackView.Alignment,
					   distribution: UIStackView.Distribution,
					   spacing: CGFloat,
					   insets: NSDirectionalEdgeInsets?) {
		addArrangedSubviews(views)
		self.axis = axis
		self.alignment = alignment
		self.distribution = distribution
		self.spacing = spacing
		if let insets = insets {
			self.directionalLayoutMargins = insets
			self.isLayoutMarginsRelativeArrangement = true
		}
	}

	/// Removes all arranged subviews from the view
	@objc func removeAllArrangedSubviews() {
		arrangedSubviews.forEach {reallyRemoveArrangedSubview($0)}
	}

	/// really removes a subview from the arrang list as well as from the view
	@objc func reallyRemoveArrangedSubview(_ view: UIView) {
		removeArrangedSubview(view)
		view.removeFromSuperview()
	}

	/// add multiple arranged subviews
	@objc func addArrangedSubviews(_ subviews: [UIView]) {
		subviews.forEach {addArrangedSubview($0)}
	}

	/// adds multiple arranged subviews
	func addArrangedSubviews(_ subviews: UIView...) {
		addArrangedSubviews(subviews)
	}

	/// replaces all arranged subviews
	@objc func replaceArrangedSubviews(with subviews: [UIView]) {
		removeAllArrangedSubviews()
		addArrangedSubviews(subviews)
	}

	/// replaces all arranged subviews
	func replaceArrangedSubviews(with subviews: UIView...) {
		removeAllArrangedSubviews()
		addArrangedSubviews(subviews)
	}
}
