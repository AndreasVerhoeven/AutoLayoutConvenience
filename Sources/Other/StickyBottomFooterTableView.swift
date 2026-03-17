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
			reallyUpdateStickyFooterViewLayout(canAnimate: false)
		}
	}
	
	/// the blur effect to apply when the sticky footer has sticked to the bottom of the table view.
	/// Defaults to `UIBlurEffect(style: .systemChromeMaterial)` before iOS 26,
	/// to `nil` on iOS 26 and higher.
	public var stickyFooterBlurEffect: UIBlurEffect? {
		didSet {
			reallyUpdateStickyFooterViewLayout(canAnimate: false)
		}
	}

	/// if true, on iOS 26 this will apply a scroll edge element to the tableview behind
	/// the sticky footer view. Defaults to `true` on iOS26+, `false` otherwise.
	///
	/// Note, UIKit currently only uses this if there isn't already another edge, such as a
	/// tab bar. If there is, this edge will sadly be ignored.
	public var stickyFooterUsesScrollEdgeElement = false {
		didSet {
			guard stickyFooterUsesScrollEdgeElement != oldValue else { return }
			updateScrollEdgeElementContainerInteraction(shouldShow: stickingState.isSticking)
		}
	}

	/// the state of our sticking
	public enum StickingState {
		case followingContent /// we're not sticking to anything
		case bottomOfSafeArea /// sticking to the safe area
		case bottomOfKeyboard /// sticking to the keyboard

		/// true if we're sticking to something
		public var isSticking: Bool {
			switch self {
				case .followingContent: return false
				case .bottomOfSafeArea: return true
				case .bottomOfKeyboard: return true
			}
		}
	}

	/// holds if we are sticking the bottom view to something and if so to what.
	/// Use `footerStickinessChangedCallback` to be notified when this changes.
	public private(set) var stickingState = StickingState.followingContent {
		didSet {
			guard stickingState != oldValue else { return }
			ensureStickyFooterViewIsAtFront {}
			footerStickinessChangedCallback?()
		}
	}

	/// will be called when `stickingState` changes
	public var footerStickinessChangedCallback: (() -> Void)?

	/// the sticky footer mode
	public enum StickyFooterMode: CaseIterable {
		case automatic /// same as `.onBottomWhenScrolledOutOfView` right now
		case alwaysOnBottom /// always stick to the bottom if there is enough space for the content
		case alwaysBelowContent /// always below the content

		/// sticks to the bottom when scrolled out of view and there is enough space, otherwise below the content
		/// (you can see this as the footer being attached to the content, but it will never scroll out of view normally)
		case onBottomWhenScrolledOutOfView

		/// sticks to the bottom if there is enough space but avoids the content
		/// (you can see this as the footer being attached to the bottom, but getting pushed out by the content)
		case onBottomWhenNotOverlappingContent

	}
	
	/// the mode to use for the sticky footer. Changes can be animated when wrapped in an animation block.
	public var stickyFooterMode: StickyFooterMode = .automatic {
		didSet {
			guard stickyFooterMode != oldValue else { return }
			reallyUpdateStickyFooterViewLayout(canAnimate: false)
		}
	}

	/// if true, we avoid the keyboard and we see the top of the keyboard as where to stick the footer view to.
	/// Changes can be animated when wrapped in an animation block.
	public var stickyFooterAvoidsKeyboard = true {
		didSet {
			guard stickyFooterAvoidsKeyboard != oldValue else { return }
			updateKeyboardTracking()
			reallyUpdateStickyFooterViewLayout(canAnimate: false)
		}
	}

	/// the spacing we keep on top of the keyboard to the contents (the sticky footer or the contents of the table view).
	/// Changes can be animated when wrapped in an animation block.
	public var stickyFooterSpacingToKeyboard = CGFloat(0) {
		didSet {
			guard stickyFooterSpacingToKeyboard != oldValue else { return }
			reallyUpdateStickyFooterViewLayout(canAnimate: false)
		}
	}

	/// the required height for the content. If sticking a button to the bottom of the safe area or keyboard
	/// would result into less height available for the actual table view content than this value, we won't
	/// stick the button.
	/// Changes can be animated when wrapped in an animation block.
	public var stickyFooterRequiredAvailableContentHeight = CGFloat(0) {
		didSet {
			guard stickyFooterRequiredAvailableContentHeight != oldValue else { return }
			reallyUpdateStickyFooterViewLayout(canAnimate: false)
		}
	}

	/// determines how the table content is aligned when it's not scrollable,
	/// alignment is done by modifying `contentInset.top`
	public enum TableContentAlignment: CaseIterable {
		case `default` /// default table view alignment, same as `.top`
		case top /// content is aligned to top
		case center /// content is aligned in the middle
		case bottom /// content is aligned to the bottom
	}

	/// determines how the table content (the rows and headers etc) are aligned. Alignment is done by
	/// modifying `contentInset.top`
	public var stickyFooterTableContentAlignment = TableContentAlignment.default {
		didSet {
			guard stickyFooterTableContentAlignment != oldValue else { return }
			reallyUpdateStickyFooterViewLayout(canAnimate: false)
		}
	}

	// MARK: - Private
	private var animationCount = 0
	private var updateStickyFooterViewLayoutCount = 0
	private var isUpdatingRowsCount = 0
	private var stickyFooterViewConstraintsList: ConstraintsList!
	private var wrapperViewConstraintsList: ConstraintsList!
	private var keyboardTrackerCancellable: KeyboardTracker.Cancellable?

	private let stickyFooterWrapperView = UIView()
	private let stickyFooterBlurView = UIVisualEffectView()

	private var stickyFooterScrollEdgeElementContainerInteractionInternal: Any?

	private static let uiScrollSubview = "U*I*S*c*r*o*l*l".replacingOccurrences(of: "*", with: "")

	private func updateStickyFooterViewLayout() {
		if animationCount > 0 {
			UIView.animate(withDuration: 0.25, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
				self.reallyUpdateStickyFooterViewLayout()
				self.stickyFooterWrapperView.layoutIfNeeded()
			}
		} else {
			reallyUpdateStickyFooterViewLayout()
		}
	}
	
	private func reallyUpdateStickyFooterViewLayout(canAnimate: Bool = true) {
		guard updateStickyFooterViewLayoutCount == 0 else { return }
		
		updateStickyFooterViewLayoutCount += 1

		let scale = (window?.screen.scale ?? UIScreen.main.scale)
		func scaleToPixels(_ value: CGFloat) -> CGFloat {
			return round(value * scale)
		}

		func roundToPoints(_ value: CGFloat) -> CGFloat {
			return scaleToPixels(value) / scale
		}

		// first, determine what we see as a bottom boundary, either the keyboard or the safe area
		var bottomInset: CGFloat
		var keyboardAdjustmentBottomInset: CGFloat
		let isUsingKeyboardAsBottomBoundary: Bool
		if stickyFooterAvoidsKeyboard == true && KeyboardTracker.shared.isKeyboardVisible == true {
			keyboardAdjustmentBottomInset = KeyboardTracker.shared.effectiveContentInset(
				view: self,
				ignoreHierarchyTransforms: true,
				ignoreViewScrollOffset: true
			).bottom
			bottomInset = max(keyboardAdjustmentBottomInset, safeAreaInsets.bottom)
			isUsingKeyboardAsBottomBoundary = (keyboardAdjustmentBottomInset > safeAreaInsets.bottom)

			if isUsingKeyboardAsBottomBoundary == true {
				keyboardAdjustmentBottomInset += stickyFooterSpacingToKeyboard
				bottomInset += stickyFooterSpacingToKeyboard
			}
		} else {
			bottomInset = safeAreaInsets.bottom
			keyboardAdjustmentBottomInset = 0
			isUsingKeyboardAsBottomBoundary = false
		}

		// determine if we should stick or not by checking if the contents is past the "bottom"
		// (of either the keyboard or safe area)
		let contentBottomY = roundToPoints(contentSize.height - contentOffset.y - contentInset.top)
		let visibleScrollFrameY = roundToPoints(bounds.height - bottomInset - stickyFooterView.bounds.height)

		// calculate how much translation we need to follow the contents and check if we actually
		// fit if we would stick
		let neededTranslationToFollowContents = roundToPoints(visibleScrollFrameY - contentBottomY + (isUsingKeyboardAsBottomBoundary == true ? 0 : bottomInset))
		let hasEnoughSpaceForContent = scaleToPixels(visibleScrollFrameY - safeAreaInsets.top) >= scaleToPixels(stickyFooterRequiredAvailableContentHeight)
		let hasContentsPastBottom = (scaleToPixels(contentBottomY) >= scaleToPixels(visibleScrollFrameY))

		let translation: CGFloat
		let isSticking: Bool
		switch stickyFooterMode {
			case .automatic,
					.onBottomWhenScrolledOutOfView:
				// stick if there's content past the bottom and we fit,
				// otherwise follow the contents.
				let shouldStick = (hasContentsPastBottom == true && hasEnoughSpaceForContent == true)
				translation = (shouldStick == true ? 0 : neededTranslationToFollowContents)
				isSticking = (translation == 0)

			case .alwaysOnBottom:
				// always stick if we can fit, otherwise follow the content
				translation = (hasEnoughSpaceForContent == true ? 0 : neededTranslationToFollowContents)
				isSticking = (translation == 0)

			case .alwaysBelowContent:
				// never stick, always follow the contents
				translation = neededTranslationToFollowContents
				isSticking = false

			case .onBottomWhenNotOverlappingContent:
				// stick if there's no content past the bottom and we fit,
				// otherwise follow the contents.
				let shouldStick = (hasContentsPastBottom == false && hasEnoughSpaceForContent == true)
				translation = (shouldStick == true ? 0 : neededTranslationToFollowContents)
				isSticking = (translation == 0)

		}

		// if we use the keyboard as a boundary, we move up our wrapper view so it's
		// above the keyboard
		if isUsingKeyboardAsBottomBoundary == true {
			wrapperViewConstraintsList.insets.bottom = keyboardAdjustmentBottomInset
		} else {
			wrapperViewConstraintsList.insets.bottom = 0
		}

		// if we are sticking to the safe area, adjust the `stickyFooterView`
		// so that it's bottom is aligned to the safe area - our wrapper view
		// goes all the way to the superview bottom.
		if isSticking == true && isUsingKeyboardAsBottomBoundary == false {
			stickyFooterViewConstraintsList.insets.bottom = bottomInset
		} else {
			stickyFooterViewConstraintsList.insets.bottom = 0
		}

		let newStickingState: StickingState
		if isSticking == true {
			newStickingState = (isUsingKeyboardAsBottomBoundary == true ? .bottomOfKeyboard : .bottomOfSafeArea)
		} else {
			newStickingState = .followingContent
		}

		// animate the background accordingly
		let updates = { [self] in
			stickyFooterBlurView.effect = isSticking ? stickyFooterBlurEffect : nil
			stickyFooterWrapperView.backgroundColor = isSticking ? stickyFooterBackgroundColor : nil
			updateScrollEdgeElementContainerInteraction(shouldShow: isSticking)
		}
		
		if canAnimate == true && stickingState.isSticking != newStickingState.isSticking && window != nil {
			UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: updates)
		} else {
			updates()
		}

		// update the insets, make room for out sticky footer view
		var bottomContentInset = stickyFooterView.bounds.height

		var baseBottomContentInset = CGFloat(0)
		if isUsingKeyboardAsBottomBoundary == true {
			// if we are using the keyboard as bottom boundary, adjust the content
			// inset accordingly
			baseBottomContentInset = keyboardAdjustmentBottomInset - safeAreaInsets.bottom
			bottomContentInset += baseBottomContentInset
		}

		// update the inset and scroll indicators only when needed
		if scaleToPixels(bottomContentInset) != scaleToPixels(contentInset.bottom) {
			contentInset.bottom = bottomContentInset

			if isSticking == true {
				verticalScrollIndicatorInsets.bottom = bottomContentInset
			} else {
				verticalScrollIndicatorInsets.bottom = baseBottomContentInset
			}
		}

		let availableContentHeight = bounds.height - safeAreaInsets.top - adjustedContentInset.bottom
		let leftOverSpace = max(0, availableContentHeight - contentSize.height)

		let newTopInset: CGFloat
		switch stickyFooterTableContentAlignment {
			case .default: newTopInset = 0
			case .top: newTopInset = 0
			case .center: newTopInset = roundToPoints(leftOverSpace * 0.5)
			case .bottom: newTopInset = roundToPoints(leftOverSpace)
		}

		if scaleToPixels(contentInset.top) != scaleToPixels(newTopInset) {
			contentInset.top = newTopInset
		}

		// if we are not sticking, we want to follow the content, so we need
		// to apply a translation from our original position (pinned to bottom)
		// to where we need to end up.
		if isSticking == false {
			// because we did our translation calculation __before__ we knew how much
			// the content would be pushed down by alignment, we need to push it down
			// here by how much we inset the content from top
			let translationToUse = -translation + newTopInset
			stickyFooterWrapperView.transform = CGAffineTransform(translationX: 0, y: translationToUse)
		} else {
			stickyFooterWrapperView.transform = .identity
		}

		stickingState = newStickingState

		if UIView.inheritedAnimationDuration > 0 {
			layoutIfNeeded()
		}

		updateStickyFooterViewLayoutCount -= 1
	}

	private func ensureStickyFooterViewIsAtFront(callback: () -> Void) {
		let hasStickyFooterView = (stickyFooterWrapperView.superview != nil)

		callback()

		guard hasStickyFooterView == true else { return }

		// if we're not sticking to the bottom, we want to be behind the first scroll pocket or scroll indicator
		if stickingState.isSticking == false,
		   let index = subviews.firstIndex(where: { NSStringFromClass($0.classForCoder).contains(Self.uiScrollSubview) }) {
			let subview = index > 0 ? subviews[index - 1] : subviews[0]
			if subview !== stickyFooterWrapperView {
				super.insertSubview(stickyFooterWrapperView, belowSubview: subview)
			}
		} else {
			if subviews.last != stickyFooterWrapperView {
				super.bringSubviewToFront(stickyFooterWrapperView)
			}
		}
	}

	private func updateKeyboardTracking() {
		if stickyFooterAvoidsKeyboard == true {
			if keyboardTrackerCancellable == nil {
				keyboardTrackerCancellable = KeyboardTracker.shared.addObserver { [weak self] _ in
					guard let self else { return }

					reallyUpdateStickyFooterViewLayout(canAnimate: true)
					layoutIfNeeded()
				}
			}
		} else {
			if let keyboardTrackerCancellable {
				KeyboardTracker.shared.removeObserver(keyboardTrackerCancellable)
			}
			keyboardTrackerCancellable = nil
		}
	}

	private func updateScrollEdgeElementContainerInteraction(shouldShow: Bool) {
		guard #available(iOS 26, *) else { return }

		if stickyFooterUsesScrollEdgeElement == true && shouldShow == true {
			if stickyFooterScrollEdgeElementContainerInteractionInternal == nil {
				let interaction = UIScrollEdgeElementContainerInteraction()
				interaction.scrollView = self
				interaction.edge = .bottom
				stickyFooterView.addInteraction(interaction)
				stickyFooterScrollEdgeElementContainerInteractionInternal = interaction
			}
		} else if let interaction = stickyFooterScrollEdgeElementContainerInteractionInternal as? UIScrollEdgeElementContainerInteraction {
			stickyFooterView.removeInteraction(interaction)
			stickyFooterScrollEdgeElementContainerInteractionInternal = nil
		}
	}

	private func willBeginRowDataChange() {
		isUpdatingRowsCount += 1
	}

	private func didEndRowDataChange() {
		isUpdatingRowsCount -= 1
		if isUpdatingRowsCount == 0 {
			animationCount = 0
		}
	}

	private func trackRowsUpdate(animation: UITableView.RowAnimation, _ callback: () -> Void) {
		if animation != .none {
			animationCount += 1
		}

		willBeginRowDataChange()
		callback()
		didEndRowDataChange()
	}


	// MARK: - UITableView
	open override func performBatchUpdates(_ updates: (() -> Void)?, completion: ((Bool) -> Void)? = nil) {

		willBeginRowDataChange()
		super.performBatchUpdates({
			animationCount += 1
			updates?()
		}, completion: { [weak self] finished in
			completion?(finished)
			self?.didEndRowDataChange()
		})
	}

	open override func beginUpdates() {
		willBeginRowDataChange()
		animationCount += 1
		super.beginUpdates()
	}

	open override func endUpdates() {
		super.endUpdates()
		didEndRowDataChange()
	}

	open override func insertSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
		trackRowsUpdate(animation: animation) { super.insertSections(sections, with: animation) }
	}

	open override func deleteSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
		trackRowsUpdate(animation: animation) { super.deleteSections(sections, with: animation) }
	}

	open override func reloadSections(_ sections: IndexSet, with animation: UITableView.RowAnimation) {
		trackRowsUpdate(animation: animation) { super.reloadSections(sections, with: animation) }
	}

	open override func moveSection(_ section: Int, toSection newSection: Int) {
		trackRowsUpdate(animation: .automatic) { super.moveSection(section, toSection: newSection) }
	}

	open override func insertRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
		trackRowsUpdate(animation: animation) { super.insertRows(at: indexPaths, with: animation) }
	}

	open override func deleteRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
		trackRowsUpdate(animation: animation) { super.deleteRows(at: indexPaths, with: animation) }
	}

	open override func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
		trackRowsUpdate(animation: animation) { super.reloadRows(at: indexPaths, with: animation) }
	}

	open override func moveRow(at indexPath: IndexPath, to newIndexPath: IndexPath) {
		trackRowsUpdate(animation: .automatic) { super.moveRow(at: indexPath, to: newIndexPath) }
	}

	open override func reconfigureRows(at indexPaths: [IndexPath]) {
		trackRowsUpdate(animation: .automatic) { super.reconfigureRows(at: indexPaths) }
	}

	public override init(frame: CGRect, style: UITableView.Style) {
		if #available(iOS 26, *) {
			stickyFooterUsesScrollEdgeElement = true
		} else {
			stickyFooterUsesScrollEdgeElement = false
			stickyFooterBlurEffect = UIBlurEffect(style: .systemChromeMaterial)
		}

		super.init(frame: frame, style: style)

		stickyFooterWrapperView.preservesSuperviewLayoutMargins = true
		stickyFooterView.preservesSuperviewLayoutMargins = true

		stickyFooterWrapperView.addSubview(stickyFooterBlurView, filling: .superview)
		stickyFooterViewConstraintsList = stickyFooterWrapperView.addSubview(stickyFooterView, filling: .superview)
		wrapperViewConstraintsList = addSubview(stickyFooterWrapperView, pinning: .bottom, to: .bottom, of: .scrollFrame, horizontally: .filling(.scrollFrame))

		updateKeyboardTracking()
		reallyUpdateStickyFooterViewLayout(canAnimate: false)
	}

	// MARK: - UIScrollView
	open override var contentSize: CGSize {
		didSet {
			guard contentSize != oldValue else { return }
			updateStickyFooterViewLayout()
		}
	}
	
	// MARK: - UIView
	open override var bounds: CGRect {
		didSet {
			guard bounds != oldValue else { return }
			updateStickyFooterViewLayout()
		}
	}
	
	open override func adjustedContentInsetDidChange() {
		super.adjustedContentInsetDidChange()
		updateStickyFooterViewLayout()
	}
	
	open override func safeAreaInsetsDidChange() {
		super.safeAreaInsetsDidChange()
		updateStickyFooterViewLayout()
	}
	
	open override func layoutSubviews() {
		super.layoutSubviews()
		
		reallyUpdateStickyFooterViewLayout()
	}

	public override func addSubview(_ view: UIView) {
		ensureStickyFooterViewIsAtFront {
			super.addSubview(view)
		}
	}

	public override func insertSubview(_ view: UIView, at index: Int) {
		ensureStickyFooterViewIsAtFront {
			super.insertSubview(view, at: index)
		}
	}

	public override func insertSubview(_ view: UIView, aboveSubview siblingSubview: UIView) {
		ensureStickyFooterViewIsAtFront {
			super.insertSubview(view, aboveSubview: siblingSubview)
		}
	}

	public override func exchangeSubview(at index1: Int, withSubviewAt index2: Int) {
		ensureStickyFooterViewIsAtFront {
			super.exchangeSubview(at: index1, withSubviewAt: index2)
		}
	}

	public override func bringSubviewToFront(_ view: UIView) {
		ensureStickyFooterViewIsAtFront {
			super.bringSubviewToFront(view)
		}
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
