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
	public let stickyFooterView: UIView

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
		case top /// content is aligned to top
		case center /// content is aligned in the middle
		case bottom /// content is aligned to the bottom
	}

	/// determines how the table content (the rows and headers etc) are aligned. Alignment is done by
	/// modifying `contentInset.top`
	public var stickyFooterTableContentAlignment = TableContentAlignment.top {
		didSet {
			guard stickyFooterTableContentAlignment != oldValue else { return }
			reallyUpdateStickyFooterViewLayout(canAnimate: false)
		}
	}

	// MARK: - Privates

	/// subclasses to be able to properly debug the view hierarchy by giving views an
	/// easy to recognize name
	private final class StickyFooterView: UIView {}
	private final class StickyFooterWrapperView: UIView {}

	private var animationCount = 0
	private var updateStickyFooterViewLayoutCount = 0
	private var isUpdatingRowsCount = 0
	private var stickyFooterViewConstraintsList: ConstraintsList!
	private var wrapperViewConstraintsList: ConstraintsList!
	private var keyboardTrackerCancellable: KeyboardTracker.Cancellable?

	private let stickyFooterWrapperView = StickyFooterWrapperView()
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
		// this method is not re-entrant to avoid layout loops, so check for that.
		guard updateStickyFooterViewLayoutCount == 0 else { return }
		updateStickyFooterViewLayoutCount += 1
		defer { updateStickyFooterViewLayoutCount -= 1 }

		// helper methods to scale and apply layout
		let scale = (window?.screen.scale ?? UIScreen.main.scale)
		func scaleToPixels(_ value: CGFloat) -> CGFloat { round(value * scale) }
		func roundToPoints(_ value: CGFloat) -> CGFloat { scaleToPixels(value) / scale }
		func set<T: AnyObject>(_ object: T, _ keyPath: ReferenceWritableKeyPath<T, CGFloat>, to value: CGFloat) {
			guard scaleToPixels(object[keyPath: keyPath]) != scaleToPixels(value) else { return }
			object[keyPath: keyPath] = value
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

		/// structure that holds all the values we need for layout
		struct Layout {
			var isSticking = false
			var translation = CGFloat(0)
			var bottomInset = CGFloat(0)
			var topInset = CGFloat(0)
			var scrollIndicatorBottomInset = CGFloat(0)
			var wrapperViewBottomInset = CGFloat(0)
			var footerViewBottomInset = CGFloat(0)
		}

		/// helper method to determine layout - this is a helper method, because we do a 2 pass-layout in some instances
		func determineLayout(topInsetToUse: CGFloat = 0) -> Layout {
			// determine if we should stick or not by checking if the contents is past the "bottom"
			// (of either the keyboard or safe area)
			let contentBottomY = roundToPoints(contentSize.height - contentOffset.y - contentInset.top + topInsetToUse)
			let visibleScrollFrameY = roundToPoints(bounds.height - bottomInset - stickyFooterView.bounds.height)

			// calculate how much translation we need to follow the contents and check if we actually
			// fit if we would stick
			let neededTranslationToFollowContents = roundToPoints(visibleScrollFrameY - contentBottomY + (isUsingKeyboardAsBottomBoundary == true ? 0 : bottomInset))
			let hasEnoughSpaceForContent = scaleToPixels(visibleScrollFrameY - safeAreaInsets.top) >= scaleToPixels(stickyFooterRequiredAvailableContentHeight)
			let hasContentsPastBottom = (scaleToPixels(contentBottomY) >= scaleToPixels(visibleScrollFrameY))

			var layout = Layout()
			switch stickyFooterMode {
				case .automatic,
						.onBottomWhenScrolledOutOfView:
					// stick if there's content past the bottom and we fit,
					// otherwise follow the contents.
					let shouldStick = (hasContentsPastBottom == true && hasEnoughSpaceForContent == true)
					layout.translation = (shouldStick == true ? 0 : neededTranslationToFollowContents)
					layout.isSticking = (layout.translation == 0)

				case .alwaysOnBottom:
					// always stick if we can fit, otherwise follow the content
					layout.translation = (hasEnoughSpaceForContent == true ? 0 : neededTranslationToFollowContents)
					layout.isSticking = (layout.translation == 0)

				case .alwaysBelowContent:
					// never stick, always follow the contents
					layout.translation = neededTranslationToFollowContents
					layout.isSticking = false

				case .onBottomWhenNotOverlappingContent:
					// stick if there's no content past the bottom and we fit,
					// otherwise follow the contents.
					let shouldStick = (hasContentsPastBottom == false && hasEnoughSpaceForContent == true)
					layout.translation = (shouldStick == true ? 0 : neededTranslationToFollowContents)
					layout.isSticking = (layout.translation == 0)
			}

			// calculate bottom inset
			layout.bottomInset = stickyFooterView.bounds.height
			var baseBottomContentInset = CGFloat(0)
			if isUsingKeyboardAsBottomBoundary == true {
				// if we are using the keyboard as bottom boundary, adjust the content
				// inset accordingly
				baseBottomContentInset = keyboardAdjustmentBottomInset - safeAreaInsets.bottom
				layout.bottomInset += baseBottomContentInset
			}

			// calculate scroll indicator bottom inset
			if layout.isSticking == true {
				layout.scrollIndicatorBottomInset = layout.bottomInset
			} else {
				layout.scrollIndicatorBottomInset = baseBottomContentInset
			}

			// calculate top inset
			let availableContentHeight = bounds.height - safeAreaInsets.top - safeAreaInsets.bottom - layout.bottomInset
			let leftOverSpace = max(0, availableContentHeight - contentSize.height)
			switch stickyFooterTableContentAlignment {
				case .top: layout.topInset = 0
				case .center: layout.topInset = roundToPoints(leftOverSpace * 0.5)
				case .bottom: layout.topInset = roundToPoints(leftOverSpace)
			}

			if layout.isSticking == false {
				// ensure translation makes sense by adjusting for the top inset
				switch stickyFooterMode {
					case .automatic,
							.alwaysOnBottom,
							.alwaysBelowContent,
							.onBottomWhenScrolledOutOfView:
						layout.translation -= layout.topInset

					case .onBottomWhenNotOverlappingContent:
						// don't adjust, not sticking is the odd-one
						break
				}
			} else {
				layout.translation = 0
			}

			// if we use the keyboard as a boundary, we move up our wrapper view so it's
			// above the keyboard, otherwise we move up the footer view to adjust for
			// bottom inset when we are not sticky.
			if isUsingKeyboardAsBottomBoundary == true {
				layout.wrapperViewBottomInset = keyboardAdjustmentBottomInset
			} else if layout.isSticking == true {
				layout.footerViewBottomInset = bottomInset
			}

			return layout
		}

		// determine our layout - if we have top inset, do a second pass, because
		// some of the layout depends on that.
		var layout = determineLayout()
		if layout.topInset != 0 {
			// if we have a top we might actually need to change our sticking,
			// because we calculate the layout without top inset first. So,
			// check if our sticking changes when using a top inset and if so,
			// use the new layout.
			let newLayout = determineLayout(topInsetToUse: layout.topInset)
			if newLayout.isSticking != layout.isSticking {
				layout = newLayout
			}
		}

		// set all layout by using a helper function that first checks for actual differences.
		set(wrapperViewConstraintsList, \.insets.bottom, to: layout.wrapperViewBottomInset)
		set(stickyFooterViewConstraintsList, \.insets.bottom, to: layout.footerViewBottomInset)
		set(self, \.contentInset.bottom, to: layout.bottomInset)
		set(self, \.verticalScrollIndicatorInsets.bottom, to: layout.scrollIndicatorBottomInset)

		// WORKAROUND (iOS 14+, *): UIKit doesn't always update `frameLayoutGuide`
		// correctly when changing topInset: resulting in the sticky footer view not
		// showing at the correct position. We need to force a change by wiggling it
		// the topInset with 1 point - while ignoring `setNeedsLayout()` to avoid
		// an endless layout loop.
		set(self, \.contentInset.top, to: layout.topInset)

		stickyFooterWrapperView.transform = CGAffineTransform(translationX: 0, y: -layout.translation)

		// update our background: if we are sticky we show the background (effect, color, scroll edge),
		// if not, we remove the backgrounds.
		let updates = { [self] in
			stickyFooterBlurView.effect = layout.isSticking ? stickyFooterBlurEffect : nil
			stickyFooterWrapperView.backgroundColor = layout.isSticking ? stickyFooterBackgroundColor : nil
			updateScrollEdgeElementContainerInteraction(shouldShow: layout.isSticking)
		}
		
		if canAnimate == true && stickingState.isSticking != layout.isSticking && window != nil {
			UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: updates)
		} else {
			updates()
		}

		// update our local state
		if layout.isSticking == true {
			stickingState = (isUsingKeyboardAsBottomBoundary == true ? .bottomOfKeyboard : .bottomOfSafeArea)
		} else {
			stickingState = .followingContent
		}

		// if we are in an animation block, do an actual layout pass,
		// so our layout is updated with animation
		if UIView.inheritedAnimationDuration > 0 {
			layoutIfNeeded()
		}
	}

	private func ensureStickyFooterViewIsAtFront(callback: () -> Void) {
		let hasStickyFooterView = (stickyFooterWrapperView.superview != nil)

		callback()

		guard hasStickyFooterView == true else { return }

		// if we're not sticking to the bottom, we want to be behind the first scroll pocket or scroll indicator
		if stickingState.isSticking == false,
		   let index = subviews.firstIndex(where: { NSStringFromClass($0.classForCoder).contains(Self.uiScrollSubview) }) {
			let subviewToInsertBelow = subviews[index]
			let subview = index > 0 ? subviews[index] : subviews[0]
			if subview !== stickyFooterWrapperView {
				super.insertSubview(stickyFooterWrapperView, belowSubview: subviewToInsertBelow)
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
			if animationCount > 0 {
				updateStickyFooterViewLayout()
			}
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
		stickyFooterView = StickyFooterView()

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

			// if we are in an animated update, we'll wait until the
			// end of the update block, which will fire off an update anyways -
			// this ensure that the table view updates its `frameLayoutGuide`
			// correctly.
			if animationCount == 0 {
				updateStickyFooterViewLayout()
			}
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
