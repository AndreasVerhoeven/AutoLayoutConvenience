//
//  ContentWithFooterView.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 02/05/2021.
//

import UIKit

/// A view that has (scrollable) content and a footer
public class ContentWithFooterView: UIView {
	// helper views, laid out to fit the whole width of the screen, so that
	// the scrollview can be scrolled from the full width of this view and the
	// scroll indicators show up at the sides correctly.
	public let stackView = UIStackView(axis: .vertical, insets: .zero)
	public let scrollView = VerticalOverflowScrollView()

	// we wrap our footerview into wrapper, so our footer is aligned to the readableContentGuide
	private let footerWrapperView = UIView()
	private var footerConstraintsList: ConstraintsList!

	/// The insets of the footer content
	public var footerContentInsets: NSDirectionalEdgeInsets { // defaults to 8 horizontally
		get { footerConstraintsList.insets }
		set { footerConstraintsList.insets = newValue }
	}

	/// The spacing between footer and content
	public var footerContentSpacing: CGFloat { // defaults to 0
		get { stackView.spacing }
		set { stackView.spacing = newValue }
	}

	/// The spacing below the footer
	public var bottomSpacing: CGFloat = 16 { // defaults to 16 when not vertically compact
		didSet {
			handleTraitCollection()
		}
	}

	/// The view to add content to, will become scrollable when needed.
	/// Aligned to the readable layout guide horizontally.
	public let contentView = UIView()

	/// The footer view to add content to.
	/// Aligned to the readable layout guide horizontally.
	public let footerView = UIView()

	/// Set to true to hide the footer view
	public var isFooterViewHidden: Bool {
		get {footerWrapperView.isHidden}
		set {footerWrapperView.isHidden = newValue}
	}

	/// Set to false to disable scrolling of the content view
	public var isScrollEnabled: Bool {
		get { scrollView.isScrollEnabled }
		set {
			scrollView.isScrollEnabled = newValue
		}
	}

	/// Flashes the content view scroll indicators
	public func flashScrollIndicators() {
		scrollView.flashScrollIndicators()
	}

	/// Adds a view that fills the content view
	public func addContentView(_ view: UIView) {
		contentView.addSubview(view, filling: .superview)
	}

	/// Adds a view that fills the contentview and centers vertically
	public func addCenteredContentView(_ view: UIView) {
		contentView.addSubview(view.verticallyCentered().disallowVerticalGrowing(), filling: .superview)
	}

	/// Adds a filling view to the footer
	public func addFooterView(_ view: UIView) {
		footerView.addSubview(view, filling: .superview)
	}

	/// Returns the size that fits for a certain width
	public func fittingSize(for width: CGFloat) -> CGSize {
		var height = contentView.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow).height

		if footerWrapperView.isHidden == false {
			height += stackView.spacing
			height += footerWrapperView.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow).height
			height += bottomSpacing * 2
		}

		return CGSize(width: width, height: height)
	}

	// MARK: - Private
	private func setup() {
		scrollView.addOverflowingSubview(contentView, horizontally: .readableContent)
		footerConstraintsList = footerWrapperView.addSubview(footerView, filling: .readableContent, insets: .horizontal(8))

		stackView.addArrangedSubviews(scrollView, footerWrapperView)
		addSubview(stackView, filling: .top(.safeArea, others: .superview))

		contentView.setContentHuggingPriority(.required, for: .horizontal)

		handleTraitCollection()
	}

	private func handleTraitCollection() {
		if traitCollection.verticalSizeClass == .compact {
			stackView.directionalLayoutMargins = .zero
		} else {
			stackView.directionalLayoutMargins = .bottom(bottomSpacing)
		}
	}

	// MARK: - UIView
	override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(previousTraitCollection)
		handleTraitCollection()
	}

	override public init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required public init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
}
