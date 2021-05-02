//
//  MinimumHeightTableViewCell.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 28/04/2021.
//

import UIKit

/// A UITableView cell that optionally enforces a minimum height
/// for self sizing cells
public class MinimumHeightTableCell: UITableViewCell {

	/// The defaults height used for all instances of this class
	public static var defaultMinimumHeight: CGFloat? = nil

	/// The minimum height for this cell for AutoLayout purposes:
	/// if nil, no minimum height will be enforced
	public var minimumHeight: CGFloat? = MinimumHeightTableCell.defaultMinimumHeight {
		didSet {
			guard minimumHeight != oldValue else { return }
			invalidateIntrinsicContentSize()
		}
	}

	// MARK: - UITableViewCell
	override public func systemLayoutSizeFitting(_ targetSize: CGSize, withHorizontalFittingPriority horizontalFittingPriority: UILayoutPriority, verticalFittingPriority: UILayoutPriority) -> CGSize {
		let size = super.systemLayoutSizeFitting(targetSize, withHorizontalFittingPriority: horizontalFittingPriority, verticalFittingPriority: verticalFittingPriority)
		guard let minimumHeight = minimumHeight else { return size }
		return CGSize(width: size.width, height: max(size.height, minimumHeight))
	}
}

