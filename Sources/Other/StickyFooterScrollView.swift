//
//  StickyFooterScrollView.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 19/03/2026.
//

import UIKit

/// A scroll view that has a sticky footer.
open class StickyFooterScrollView: UIScrollView, StickyFooterView.Provider {
	// MARK: StickyFooterView.Provider

	/// the sticky footer view for this scroll view. Configure its properties to determine how it works
	/// and add views to it using AutoLayout.
	public let stickyFooterView = StickyFooterView()

	// MARK: - UIScrollView
	open override var contentSize: CGSize {
		didSet {
			guard contentSize != oldValue else { return }
			stickyFooterView.scrollViewDidChangeContentSize()
		}
	}

	// MARK: - UIView

	public override init(frame: CGRect) {
		super.init(frame: frame)
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
