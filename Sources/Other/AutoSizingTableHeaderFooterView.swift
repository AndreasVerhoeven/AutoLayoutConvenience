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
	
	/// The stack view caches intrinsicContentsize changes in the view and will notify us so we can update our size
	private let stackView = CallbackStackView(axis: .horizontal, alignment: .top, distribution: .fill)
	private var isInitialLayoutCycle = true
	private var isInUpdateHeaderViewCount = 0
	
	/// This view stops AutoLayout messages from bubbling up to parent views
	private let wrapperView = UIView()
	
	/// Creates an `AutoSizingTableHeaderFooterView` with a given view
	public init(view: UIView) {
		self.view = view
		super.init(frame: .zero)
		
		preservesSuperviewLayoutMargins = true
		view.preservesSuperviewLayoutMargins = true
		wrapperView.preservesSuperviewLayoutMargins = true
		stackView.preservesSuperviewLayoutMargins = true
		
		stackView.callback = { [weak self] in self?.updateHeaderView() }
		stackView.addArrangedSubview(view)
		wrapperView.addSubview(stackView, filling: .superview)
	}
	
	@available(*, unavailable)
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	// MARK: - Privates
	private func updateHeaderView() {
		guard let tableView = superview as? UITableView else { return }
		guard tableView.tableHeaderView == self || tableView.tableFooterView == self else { return }
		let width = tableView.bounds.width
		guard width > 0 else { return }
		
		// figure out the size of our view and make sure the height matches
		let wantedSize = view.systemLayoutSizeFitting(CGSize(width: width, height: UIView.layoutFittingCompressedSize.height), withHorizontalFittingPriority: .required, verticalFittingPriority: .defaultLow)
		guard wantedSize.height != bounds.height else { return }
		
		isInUpdateHeaderViewCount += 1
		guard isInUpdateHeaderViewCount == 1 else { return }
		
		let updates = {
			// update our frame
			self.frame = CGRect(origin: .zero, size: CGSize(width: width, height: wantedSize.height))
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
		
		if automaticallyAnimateChanges == false || bounds.height == 0 || isInitialLayoutCycle == true || isInUpdateHeaderViewCount > 1 {
			if bounds.height > 0 {
				isInitialLayoutCycle = false
			}
			updates()
		} else {
			UIView.animate(withDuration: 1, delay: 0, options: [.allowUserInteraction, .allowAnimatedContent, .beginFromCurrentState], animations: updates)
		}
		
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
		
		if notYetAdded == true {
			updateHeaderView()
		}
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
	/// The given view will automatically size the `tableHeaderView`
	public var autoSizingTableHeaderView: UIView? {
		get { (tableHeaderView as? AutoSizingTableHeaderFooterView)?.view }
		set { tableHeaderView = newValue.flatMap { AutoSizingTableHeaderFooterView(view: $0) } ?? nil }
	}
	
	/// sets a `tableFooterView` wrapped in an `AutoSizingTableHeaderFooterView`
	/// The given view will automatically size the `tableFooterView`
	public var autoSizingTableFooterView: UIView? {
		get { (tableFooterView as? AutoSizingTableHeaderFooterView)?.view }
		set { tableFooterView = newValue.flatMap { AutoSizingTableHeaderFooterView(view: $0) } ?? nil }
	}
}
