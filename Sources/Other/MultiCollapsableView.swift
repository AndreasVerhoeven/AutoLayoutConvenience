//
//  MultiCollapsableView.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 02/04/2025.
//

import UIKit

/// This is a view that holds a list of views that can be collapsed to (0 height/width)
/// or expanded to their actual width. It works the same as `CollapsableView`,
/// but for multiple views, stacked.
///
/// Set the `views` property to the views you want to display and then use
/// `setIsExpanded(_:animated:)` or `isExpanded` to set
/// multiple views in one go.
///
/// You can also define spacing using the `spacing` property. If you want
/// spacing after the last item as well, set `hasSpacingAfterLastItem`
/// to true.
open class MultiCollapsableView: UIView {
	let stackView = UIStackView(axis: .vertical, alignment: .fill, distribution: .fill, spacing: 0)

	/// Creates a MultiCollapsableView for a given edge and views
	convenience init(edge: CollapsableView.Edge, animationOptions: CollapsableView.AnimationOptions = .default, views: [UIView] = []) {
		self.init(frame: .zero)
		_ = {
			self.edge = edge
			self.views = views
		}()
	}

	/// Creates a MultiCollapsableView that defaults to the top edge for a list of given views.
	convenience init( views: [UIView]) {
		self.init(frame: .zero)
		_ = {
			self.views = views
		}()
	}

	/// The list of views. Setting different views resets all `isExpanded` values to `true`
	open var views = [UIView]() {
		didSet {
			guard views != oldValue else { return }
			recreateCollapsableViewsAndSpacers()
		}
	}

	/// The amount of spacing between items, default to `8`.
	open var spacing: CGFloat = 8 {
		didSet {
			guard spacing != oldValue else { return }
			updateSpacersSize()
		}
	}

	/// The amount of spacing before the first item - will only show if there are expanded items
	open var spacingBeforeFirstItem: CGFloat = 0 {
		didSet {
			guard spacingBeforeFirstItem != oldValue else { return }

			if spacingBeforeFirstItem > 0 {
				if beforeFirstItemSpacer == nil {
					let spacer = CollapsableView()
					beforeFirstItemSpacer = spacer
					spacer.isExpanded = hasAnExpandedView
					stackView.insertArrangedSubview(spacer, at: 0)
				}
				updateBeforeAndAfterSpacers()
			} else {
				if let beforeFirstItemSpacer {
					stackView.removeArrangedSubview(beforeFirstItemSpacer)
					self.beforeFirstItemSpacer = nil
				}
			}
		}
	}

	/// The amount of spacing after the last item - will only show if there are expanded items
	open var spacingAfterLastItem: CGFloat = 0 {
		didSet {
			guard spacingAfterLastItem != oldValue else { return }

			if spacingAfterLastItem > 0 {
				if afterLastItemSpacer == nil {
					let spacer = CollapsableView()
					afterLastItemSpacer = spacer
					spacer.isExpanded = hasAnExpandedView
					stackView.addArrangedSubview(spacer)
				}
				updateBeforeAndAfterSpacers()
			} else {
				if let afterLastItemSpacer {
					stackView.removeArrangedSubview(afterLastItemSpacer)
					self.afterLastItemSpacer = nil
				}
			}
		}
	}

	/// The `AnimationOptions` to use for each view.
	open var animationOptions: CollapsableView.AnimationOptions = .default {
		didSet {
			guard animationOptions != oldValue else { return }

			updateProperties(of: collapsableViews)
			updateProperties(of: spacers)
		}
	}

	/// The edge to collapse towards.
	open var edge: CollapsableView.Edge = .top {
		didSet {
			guard edge != oldValue else { return }

			updateStackView()
			updateProperties(of: collapsableViews)
			updateProperties(of: spacers)
			updateSpacersSize()
			updateBeforeAndAfterSpacers()
		}
	}

	/// A associative list of views and their `isExpanded` status.
	open var isExpanded: [UIView: Bool] {
		get {
			var list = [UIView: Bool]()
			for (index, view) in views.enumerated() {
				list[view] = collapsableViews[index].isExpanded
			}
			return list
		}
		set {
			setIsExpanded(newValue, animated: false)
		}
	}

	/// `true` if all views are expanded
	open var areAllViewsExpanded: Bool {
		return collapsableViews.allSatisfy { $0.isExpanded }
	}

	/// `true` if there is at least one expanded view
	open var hasAnExpandedView: Bool {
		return collapsableViews.contains { $0.isExpanded }
	}

	/// Returns `true` if the given view is expanded.
	open func isExpanded(_ view: UIView) -> Bool {
		guard let index = viewToIndexLookup[view] else { return false }
		return collapsableViews[index].isExpanded
	}

	/// Expands all views
	open func expandAll(animated: Bool) {
		for collapsableView in collapsableViews {
			collapsableView.setIsExpanded(true, animated: animated)
		}

		for spacer in spacers {
			spacer.setIsExpanded(true, animated: animated)
		}
	}

	/// Collapses all views
	open func collapseAll(animated: Bool) {
		for collapsableView in collapsableViews {
			collapsableView.setIsExpanded(false, animated: animated)
		}

		for spacer in spacers {
			spacer.setIsExpanded(false, animated: animated)
		}
	}

	/// collapses expands a single view. Use `setIsExpanded(list:animated)` to change multiple views in one
	/// go
	open func setIsExpanded(_ isExpanded: Bool, view: UIView, animated: Bool) {
		setIsExpanded([view: isExpanded], animated: animated)
	}

	/// Updates a list of views to be expanded or not: provide an associative list of views with the keys
	/// being the isExpanded property, e.g.:
	/// ```
	/// 	multiCollapsableView.setIsExpanded([
	///			redView: true,
	///			greenView: false],
	///		animated: true
	/// 	)
	/// ```
	open func setIsExpanded(_ list: [UIView: Bool], animated: Bool) {
		for (view, isExpanded) in list {
			guard let index = viewToIndexLookup[view] else { continue }

			collapsableViews[index].setIsExpanded(isExpanded, animated: animated)
		}

		var indexOfCurrentExpandedView: Int?
		var spacerIndicesToExpand = Set<Int>()
		var hasAtLeastASingleExpandedView = false
		for (index, collapsableView) in collapsableViews.enumerated() {
			if collapsableView.isExpanded == true {
				hasAtLeastASingleExpandedView = true
				if let indexOfCurrentExpandedView {
					spacerIndicesToExpand.insert(indexOfCurrentExpandedView)
				}
				indexOfCurrentExpandedView = index
			}
		}

		beforeFirstItemSpacer?.setIsExpanded(hasAtLeastASingleExpandedView, animated: animated)
		afterLastItemSpacer?.setIsExpanded(hasAtLeastASingleExpandedView, animated: animated)

		for (index, spacer) in spacers.enumerated() {
			spacer.setIsExpanded(spacerIndicesToExpand.contains(index), animated: animated)
		}
	}

	// MARK: - Privates

	private var collapsableViews = [CollapsableView]()
	private var spacers = [CollapsableView]()
	private var beforeFirstItemSpacer: CollapsableView?
	private var afterLastItemSpacer: CollapsableView?
	private var viewToIndexLookup = [UIView: Int]()

	private func recreateCollapsableViewsAndSpacers() {
		stackView.removeAllArrangedSubviews()
		collapsableViews.removeAll()
		spacers.removeAll()
		viewToIndexLookup.removeAll()

		if let beforeFirstItemSpacer {
			stackView.addArrangedSubview(beforeFirstItemSpacer)
		}

		for (index, view) in views.enumerated() {
			let collapsableView = CollapsableView(animationOptions: animationOptions, edge: edge)
			collapsableView.preservesSuperviewLayoutMargins = true
			collapsableView.contentView.addSubview(view, filling: .superview)
			collapsableViews.append(collapsableView)
			stackView.addArrangedSubview(collapsableView)

			if index < views.count {
				let spacer = CollapsableView(animationOptions: animationOptions, edge: edge)
				spacers.append(spacer)
				stackView.addArrangedSubview(spacer)
			}

			viewToIndexLookup[view] = index
		}

		if let afterLastItemSpacer {
			stackView.addArrangedSubviews(afterLastItemSpacer)
		}

		updateSpacersSize()
		updateBeforeAndAfterSpacers()
	}

	private func updateStackView() {
		switch edge {
			case .top, .bottom:
				stackView.axis = .vertical

			case .leading, .trailing:
				stackView.axis = .horizontal
		}
	}

	private func updateProperties(of collapsableViewOrSpacers: [CollapsableView]) {
		for collapsableViewOrSpacer in collapsableViewOrSpacers {
			updateProperties(of: collapsableViewOrSpacer)
		}
	}

	private func updateProperties(of collapsableViewOrSpacer: CollapsableView) {
		collapsableViewOrSpacer.animationOptions = animationOptions
		collapsableViewOrSpacer.edge = edge
	}

	private func updateSpacersSize() {
		for spacer in spacers {
			updateSpacerSize(spacer, spacing: spacing)
		}
	}

	private func updateSpacerSize(_ spacer: CollapsableView, spacing spacingAmount: CGFloat) {
		switch edge {
			case .top, .bottom:
				spacer.contentView.constrainedFixedWidth = nil
				spacer.contentView.constrainedFixedHeight = spacingAmount

			case .leading, .trailing:
				spacer.contentView.constrainedFixedWidth = spacingAmount
				spacer.contentView.constrainedFixedHeight = nil
		}
	}

	private func updateBeforeAndAfterSpacers() {
		if let beforeFirstItemSpacer {
			updateProperties(of: beforeFirstItemSpacer)
			updateSpacerSize(beforeFirstItemSpacer, spacing: spacingBeforeFirstItem)
		}

		if let afterLastItemSpacer {
			updateProperties(of: afterLastItemSpacer)
			updateSpacerSize(afterLastItemSpacer, spacing: spacingAfterLastItem)
		}
	}

	// MARK: - UIView

	public override init(frame: CGRect) {
		super.init(frame: frame)

		stackView.preservesSuperviewLayoutMargins = true
		addSubview(stackView, filling: .superview)
	}

	@available(*, unavailable)
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
