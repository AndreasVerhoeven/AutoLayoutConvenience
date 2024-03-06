//
//  StickyBottomFooterTableView.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 20/02/2024.
//

import UIKit

/// This is a TableView that has a sticky footer view: the view will stick to the bottom
/// of the table view when scrolling past the bottom, and will align to the end of the
/// content otherwise.
///
/// Note: overrides `contentInset` when needed.
public class StickyBottomFooterTableView: UITableView {
	/// the sticky footer view to add content to using AutoLayout
	public let stickyFooterView = UIView()
	
	/// the background color of the sticky footer, including safeArea, when sticked to the bottom of the table view.
	public var stickyFooterBackgroundColor: UIColor? {
		didSet {
			reallyUpdatestickyFooterViewLayout(canAnimate: false)
		}
	}
	
	/// the blur effect to apply when the sticky footer has sticked to the bottom of the table view.
	public var stickyFooterBlurEffect: UIBlurEffect? = UIBlurEffect(style: .systemChromeWithFallback) {
		didSet {
			reallyUpdatestickyFooterViewLayout(canAnimate: false)
		}
	}
	
	/// true iff the footer view is sticking to the bottom
	public private(set) var isFooterViewStickingToBottom = false {
		didSet {
			guard isFooterViewStickingToBottom != oldValue else { return }
			footerStickinessChangedCallback?()
		}
	}
	
	/// the sticky footer mode
	public enum StickyFooterMode: CaseIterable {
		case automatic // below the content when possible, stick to the bottom when overflowing
		case alwaysOnBottom // always stick to the bottom
		case alwaysBelowContent // always below the content
	}
	
	/// the mode to use for the sticky footer. Changes can be animated when wrapped in an animation block.
	public var stickyFooterMode: StickyFooterMode = .automatic {
		didSet {
			guard stickyFooterMode != oldValue else { return }
			reallyUpdatestickyFooterViewLayout(canAnimate: false)
		}
	}
	
	/// will be called when `isFooterViewStickingToBottom` changes
	public var footerStickinessChangedCallback: (() -> Void)?
	
	// MARK: - Private
	private var animationCount = 0
	private var updatestickyFooterViewLayoutCount = 0
	private var stickyFooterViewConstraintsList: ConstraintsList!
	
	private let stickyFooterWrapperView = UIView()
	private let stickyFooterBlurView = UIVisualEffectView()
	
	private func updatestickyFooterViewLayout() {
		if animationCount > 0 {
			UIView.animate(withDuration: 0.33, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
				self.reallyUpdatestickyFooterViewLayout()
				self.stickyFooterWrapperView.layoutIfNeeded()
			}
		} else {
			reallyUpdatestickyFooterViewLayout()
		}
	}
	
	private func reallyUpdatestickyFooterViewLayout(canAnimate: Bool = true) {
		guard updatestickyFooterViewLayoutCount == 0 else { return }
		
		updatestickyFooterViewLayoutCount += 1
		
		stickyFooterViewConstraintsList.insets.bottom = safeAreaInsets.bottom
		
		func neededTranslationToFollowContent() -> CGFloat {
			let contentHeight = contentSize.height
			let contentBottom = adjustedContentInset.top - contentOffset.y + contentHeight
			let stickyFooterViewY = adjustedContentInset.top + bounds.height - stickyFooterView.bounds.height
			return stickyFooterViewY - contentBottom
			
		}
		
		let translation: CGFloat
		let isSticking: Bool
		switch stickyFooterMode {
			case .automatic:
				translation = max(0, neededTranslationToFollowContent())
				isSticking = (translation == 0)
				
			case .alwaysOnBottom:
				translation = 0
				isSticking = true
				
			case .alwaysBelowContent:
				translation = neededTranslationToFollowContent()
				isSticking = false
		}
		
		stickyFooterWrapperView.transform = CGAffineTransform(translationX: 0, y: -translation)
		
		let updates = { [self] in
			stickyFooterBlurView.effect = isSticking ? stickyFooterBlurEffect : nil
			stickyFooterWrapperView.backgroundColor = isSticking ? stickyFooterBackgroundColor : nil
		}
		
		if canAnimate == true && isSticking != isFooterViewStickingToBottom && window != nil {
			UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: updates)
		} else {
			updates()
		}
		
		let scale = (window?.screen.scale ?? UIScreen.main.scale)
		let bottomContentInset = stickyFooterView.bounds.height
		if round(bottomContentInset * scale) != round(contentInset.bottom * scale) {
			contentInset.bottom = bottomContentInset
			verticalScrollIndicatorInsets.bottom = bottomContentInset
		}
		
		isFooterViewStickingToBottom = isSticking
		
		updatestickyFooterViewLayoutCount -= 1
	}
	
	// MARK: - UITableView
	public override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {
		super.performBatchUpdates({
			self.animationCount += 1
			updates?()
		}, completion: { finished in
			completion?(finished)
			self.animationCount -= 1
		})
	}
	
	
	public override init(frame: CGRect, style: UITableView.Style) {
		super.init(frame: frame, style: style)
		
		stickyFooterWrapperView.preservesSuperviewLayoutMargins = true
		stickyFooterView.preservesSuperviewLayoutMargins = true
		
		stickyFooterWrapperView.addSubview(stickyFooterBlurView, filling: .superview)
		stickyFooterViewConstraintsList = stickyFooterWrapperView.addSubview(stickyFooterView, filling: .superview)
		addSubview(stickyFooterWrapperView, pinning: .bottom, to: .bottom, of: .scrollFrame, horizontally: .filling(.scrollFrame))
	}
	
	// MARK: - UIScrollView
	open override var contentSize: CGSize {
		didSet {
			guard contentSize != oldValue else { return }
			updatestickyFooterViewLayout()
		}
	}
	
	// MARK: - UIView
	open override var bounds: CGRect {
		didSet {
			guard bounds != oldValue else { return }
			updatestickyFooterViewLayout()
		}
	}
	
	open override func adjustedContentInsetDidChange() {
		super.adjustedContentInsetDidChange()
		updatestickyFooterViewLayout()
	}
	
	open override func safeAreaInsetsDidChange() {
		super.safeAreaInsetsDidChange()
		updatestickyFooterViewLayout()
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		
		reallyUpdatestickyFooterViewLayout()
	}
	
	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}

fileprivate extension UIBlurEffect.Style {
	static var systemChromeWithFallback: Self {
		if #available(iOS 13, *) {
			return .systemChromeMaterial
		} else {
			return .regular
		}
	}
}
