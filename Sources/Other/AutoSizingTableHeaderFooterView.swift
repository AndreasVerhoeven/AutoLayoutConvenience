//
//  AutoSizingTableHeaderFooterView.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 04/03/2022.
//

import UIKit

/// This class is designed to be used as a `tableHeaderView` or `tableFooterView`
/// and will automatically change the size of that header or footer when the view changes
/// its intrinsic contentsize.
public class AutoSizingTableHeaderFooterView: UIView {
	/// the view you want to wrap
	public let view: UIView
	
	/// If this is true, changes in the size of the view will automatically be animated
	public var automaticallyAnimateChanges = true
	
	/// if this is false, we use sizeToFit() to measure the view and not auto layout.
	public var usesAutoLayout = true
	
	/// The stack view caches intrinsicContentsize changes in the view and will notify us so we can update our size
	private let stackView = CallbackStackView(axis: .horizontal, alignment: .top, distribution: .fill)
	private var isInitialLayoutCycle = true
	private var isInUpdateHeaderViewCount = 0
	private var manualLayoutHeightConstraint: NSLayoutConstraint?
	
	/// This view stops AutoLayout messages from bubbling up to parent views
	private let wrapperView = UIView()

	public typealias Callback = () -> Void

	/// will be called when we updated our layout frame
	public var didUpdateLayoutFrameCallback: Callback?

	/// Creates an `AutoSizingTableHeaderFooterView` with a given view
	public init(view: UIView) {
		self.view = view
		super.init(frame: .zero)
		
		preservesSuperviewLayoutMargins = true
		view.preservesSuperviewLayoutMargins = true
		wrapperView.preservesSuperviewLayoutMargins = true
		stackView.preservesSuperviewLayoutMargins = true
		
		stackView.callback = { [weak self] in self?.updateLayoutFrame() }
		stackView.addArrangedSubview(view)
		wrapperView.addSubview(stackView, filling: .superview)
	}
	
	/// Forces an update of this views layout - can be used with manual layout.
	public func update() {
		updateLayoutFrame()
	}
	
	/// Creates an `AutoSizingTableHeaderFooterView` with a given view that doesn't use AutoLayout
	/// but `sizeThatFits()`
	convenience init(nonAutoLayoutView view: UIView) {
		self.init(view: view)
		self.usesAutoLayout = false
	}
	
	/// presizes this view in a given table view.
	func presized(in tableView: UITableView) -> Self {
		
		// temporarily add to the table view so we have the right insets / margins
		let shouldAddToTableViewTemporarily = (superview == nil)
		if shouldAddToTableViewTemporarily == true {
			tableView.addSubview(self)
		}
		
		let wantedSize = wantedSize(for: tableView.bounds.width, usesFallbackWidth: true)
		
		// remove from the tableview if we temporarily added it
		if shouldAddToTableViewTemporarily == true {
			self.removeFromSuperview()
		}
		
		applyNewSize(wantedSize)
		return self
	}
	
	@available(*, unavailable)
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Privates
	private func wantedSize(for tableViewWidth: CGFloat, usesFallbackWidth: Bool) -> CGSize {
		let width = tableViewWidth == 0 && usesFallbackWidth == true ? UIScreen.main.bounds.width : tableViewWidth
		
		// figure out the size of our view and make sure the height matches
		let wantedSize: CGSize
		if usesAutoLayout == true {
			wantedSize = view.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
		} else {
			wantedSize = view.sizeThatFits(CGSize(width: width, height: .greatestFiniteMagnitude))
		}
		return CGSize(width: width, height: wantedSize.height)
	}
	
	private func applyNewSize(_ size: CGSize) {
		let newFrame = CGRect(origin: .zero, size: size)
		
		if self.usesAutoLayout == false {
			// when not using auto layout, we use a height constraint to force the view to have at least a height, otherwise
			// its height will be 0 in the AutoLayout world.
			self.view.frame = newFrame
			let constraint = self.manualLayoutHeightConstraint ?? self.view.heightAnchor.constraint(equalToConstant: size.height)
			self.manualLayoutHeightConstraint = constraint
			constraint.constant = size.height
			constraint.isActive = true
		}
		
		self.wrapperView.frame = newFrame
		self.frame = newFrame
	}
	
	private func updateLayoutFrame() {
		guard isInUpdateHeaderViewCount < 10 else { return }
		guard let tableView = superview as? UITableView else { return }
		guard tableView.tableHeaderView == self || tableView.tableFooterView == self else { return }
		let width = tableView.bounds.width
		guard width > 0 else { return }
		
		// figure out the size of our view and make sure the height matches
		let wantedSize = wantedSize(for: width, usesFallbackWidth: false)
		guard wantedSize.height.pixelScale != bounds.height.pixelScale else {
			isInitialLayoutCycle = false
			return
		}
		isInUpdateHeaderViewCount += 1
		
		let updates = {
			self.applyNewSize(wantedSize)
			// force re-layout for animation purposes
			self.layoutSubviews()
			self.stackView.layoutIfNeeded()
			
			// re-assign the header or footerview
			if tableView.tableHeaderView == self {
				tableView.tableHeaderView = self
			} else if tableView.tableFooterView == self {
				tableView.tableFooterView = self
			}
			tableView.layoutIfNeeded()
			tableView.setNeedsLayout()
		}
		
		if automaticallyAnimateChanges == false || bounds.height == 0 || isInitialLayoutCycle == true || isInUpdateHeaderViewCount > 1 || window == nil {
			isInitialLayoutCycle = false
			updates()
		} else {
			UIView.animate(withDuration: 0.3, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .beginFromCurrentState], animations: updates)
		}

		didUpdateLayoutFrameCallback?()

		isInUpdateHeaderViewCount -= 1
	}
	
	// MARK: - UIView
	public override func layoutSubviews() {
		super.layoutSubviews()
		
		// Only add the wrapper view in layoutSubviews(), so that we don't generate AutoLayout warnings
		let notYetAdded = (wrapperView.superview == nil)
		if notYetAdded == true {
			addSubview(wrapperView)
		}
		
		wrapperView.frame = CGRect(origin: .zero, size: bounds.size)
		updateLayoutFrame()
	}
}

extension AutoSizingTableHeaderFooterView {
	fileprivate final class CallbackStackView: UIStackView {
		var callback: (() -> Void)?
		
		override func layoutSubviews() {
			super.layoutSubviews()
			callback?()
		}
	}
}

extension UITableView {
	/// sets a `tableHeaderView` wrapped in an `AutoSizingTableHeaderFooterView`
	/// The given view will automatically size the `tableHeaderView` using AutoLayout.
	public var selfSizingTableHeaderView: UIView? {
		get { (tableHeaderView as? AutoSizingTableHeaderFooterView)?.view }
		set { tableHeaderView = newValue.flatMap { AutoSizingTableHeaderFooterView(view: $0).presized(in: self) } ?? nil }
	}
	
	/// sets a `tableFooterView` wrapped in an `AutoSizingTableHeaderFooterView`
	/// The given view will automatically size the `tableFooterView` using AutoLayout.
	public var selfSizingTableFooterView: UIView? {
		get { (tableFooterView as? AutoSizingTableHeaderFooterView)?.view }
		set { tableFooterView = newValue.flatMap { AutoSizingTableHeaderFooterView(view: $0).presized(in: self) } ?? nil }
	}
}

extension UITableView {
	/// sets a `tableHeaderView` wrapped in an `AutoSizingTableHeaderFooterView`
	/// The given view will automatically size the `tableHeaderView` using `sizeThatFits()`
	/// In order to update the size, call `updateManualLayoutAutoSizingTableHeader()`
	/// Or invalidate the `intrinsicContentSize` of the view.
	public var manualLayoutAutoSizingTableHeaderView: UIView? {
		get { (tableHeaderView as? AutoSizingTableHeaderFooterView)?.view }
		set { tableHeaderView = newValue.flatMap { AutoSizingTableHeaderFooterView(nonAutoLayoutView: $0).presized(in: self) } ?? nil }
	}
	
	/// sets a `tableFooterView` wrapped in an `AutoSizingTableHeaderFooterView`
	/// The given view will automatically size the `tableFooterView` using `sizeThatFits()`
	/// In order to update the size, call `updateManualLayoutAutoSizingTableFooter()`
	/// Or invalidate the `intrinsicContentSize` of the view.
	public var manualLayoutAutoSizingTableFooterView: UIView? {
		get { (tableFooterView as? AutoSizingTableHeaderFooterView)?.view }
		set { tableFooterView = newValue.flatMap { AutoSizingTableHeaderFooterView(nonAutoLayoutView: $0).presized(in: self) } ?? nil }
	}
	
	/// Makes the `tableHeaderView` update its layout if it's an auto-sizing one
	public func updateAutoSizingTableHeader() {
		(tableHeaderView as? AutoSizingTableHeaderFooterView)?.update()
	}
	
	/// Makes the `tableFooterView` update its layout if it's an auto-sizing one
	public func updateAutoSizingTableFooter() {
		(tableFooterView as? AutoSizingTableHeaderFooterView)?.update()
	}
}

extension CGFloat {
	fileprivate var pixelScale: Int {
		Int((self * UIScreen.main.scale).rounded())
	}
}
