//
//  StickyFooterCollectionView.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 19/03/2026.
//

import UIKit

/// `StickyFooterCollectionView` overrides `performBatchUpdates`, which has an `NS_NOESCAPE`
/// parameter in Objective-C. Swift cannot express that, so overriding this method doesn't have it.
/// Unfortunately, if this class then ends up in a bridging header, the swift->objective c conversion misses
/// the mandatory `NS_NOESCAPE` annotation and the objective-C compiler complains.
///
/// Workaround is to make sure this class is not accessible from Objective-C by making it a generic class
/// and typealiasing it here. All unfortunate, but that's swift for you.
public typealias StickyFooterCollectionView = _NonObjectiveCWorkAroundStickyFooterCollectionView<Int>

/// A collection view that has a sticky footer.
open class _NonObjectiveCWorkAroundStickyFooterCollectionView<FakeGenericUnusedParameter>: UICollectionView, StickyFooterView.Provider {
	// MARK: StickyFooterView.Provider

	/// the sticky footer view for this collection view. Configure its properties to determine how it works
	/// and add views to it using AutoLayout.
	public let stickyFooterView = StickyFooterView()

	// MARK: - UICollectionView

	open override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {

		stickyFooterView.willBeginContentUpdate()
		super.performBatchUpdates({
			updates?()
		}, completion: { [weak self] finished in
			completion?(finished)
			self?.stickyFooterView.didEndContentUpdate()
		})
	}

	open override func insertSections(_ sections: IndexSet) {
		stickyFooterView.trackCollectionViewUpdate {
			super.insertSections(sections)
		}
	}

	open override func deleteSections(_ sections: IndexSet) {
		stickyFooterView.trackCollectionViewUpdate { super.deleteSections(sections) }
	}

	open override func reloadSections(_ sections: IndexSet) {
		stickyFooterView.trackCollectionViewUpdate { super.reloadSections(sections) }
	}

	open override func moveSection(_ section: Int, toSection newSection: Int) {
		stickyFooterView.trackCollectionViewUpdate { super.moveSection(section, toSection: newSection) }
	}

	open override func insertItems(at indexPaths: [IndexPath]) {
		stickyFooterView.trackCollectionViewUpdate { super.insertItems(at: indexPaths) }
	}

	open override func deleteItems(at indexPaths: [IndexPath]) {
		stickyFooterView.trackCollectionViewUpdate { super.deleteItems(at: indexPaths) }
	}

	open override func reloadItems(at indexPaths: [IndexPath]) {
		stickyFooterView.trackCollectionViewUpdate { super.reloadItems(at: indexPaths) }
	}

	open override func moveItem(at indexPath: IndexPath, to newIndexPath: IndexPath) {
		stickyFooterView.trackCollectionViewUpdate { super.moveItem(at: indexPath, to: newIndexPath) }
	}

	@available(iOS 15, *)
	open override func reconfigureItems(at indexPaths: [IndexPath]) {
		stickyFooterView.trackCollectionViewUpdate { super.reconfigureItems(at: indexPaths) }
	}

	// MARK: - UIScrollView
	open override var contentSize: CGSize {
		didSet {
			guard contentSize != oldValue else { return }
			stickyFooterView.scrollViewDidChangeContentSize()
		}
	}

	// MARK: - UIView

	public override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
		super.init(frame: frame, collectionViewLayout: layout)
		stickyFooterView.addToScrollView(self)
	}

	open override var bounds: CGRect {
		didSet {
			guard bounds != oldValue else { return }
			stickyFooterView.scrollViewDidChangeBoundsOrInsets()
		}
	}

	open override func adjustedContentInsetDidChange() {
		super.adjustedContentInsetDidChange()
		stickyFooterView.scrollViewDidChangeBoundsOrInsets()
	}

	open override func safeAreaInsetsDidChange() {
		super.safeAreaInsetsDidChange()
		stickyFooterView.scrollViewDidChangeBoundsOrInsets()
	}

	open override func layoutSubviews() {
		super.layoutSubviews()

		stickyFooterView.scrollViewDidLayoutSubviews()
	}

	public override func addSubview(_ view: UIView) {
		stickyFooterView.ensureIsAtFront {
			super.addSubview(view)
		}
	}

	public override func insertSubview(_ view: UIView, at index: Int) {
		stickyFooterView.ensureIsAtFront {
			super.insertSubview(view, at: index)
		}
	}

	public override func insertSubview(_ view: UIView, aboveSubview siblingSubview: UIView) {
		stickyFooterView.ensureIsAtFront {
			super.insertSubview(view, aboveSubview: siblingSubview)
		}
	}

	public override func exchangeSubview(at index1: Int, withSubviewAt index2: Int) {
		stickyFooterView.ensureIsAtFront {
			super.exchangeSubview(at: index1, withSubviewAt: index2)
		}
	}

	public override func bringSubviewToFront(_ view: UIView) {
		stickyFooterView.ensureIsAtFront {
			super.bringSubviewToFront(view)
		}
	}

	@available(*, unavailable)
	required public init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
