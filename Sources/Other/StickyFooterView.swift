//
//  StickyFooterView.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 19/03/2026.
//

import UIKit

/// This class is used as the `stickyFooterView` in `StickyFooterScrollView`,
/// `StickyFooterTableView` and `StickyFooterCollectionView`.
/// You cannot instantiate this view, only use it from those views.
///
/// Configure how you would like the sticky footer to behave and how it adjusts
/// the scroll/table/collection view its part of.
///
/// Note: Using this view will override`contentInset.bottom` and
/// `contentInset.top`in the scroll view it is part of.
///
/// **Implementation note:**
/// This view has all the shared logic to modify and position itself inside
/// a scroll/table/collection view. The parent scroll/table/collection view
/// will forward certain methods to this view and it will update itself
/// and update the scrollview properties accordingly.
///
/// **Implementation details:**
///  - this view adds itself in a wrapper and then adds that wrapper to the scroll view
///  - the wrapper view is pinned to the bottom of the scroll view's __frame__, so it
///  	isn't scrolling.
///  - We inset our footer in the wrapper manually to adjust for the safe area, __if__
/// 	we're sticking to the bottom of the safe area only.
///  - Whenever the scroll view content is changed, it calculates where we should be:
///  	- either sticking to the bottom of the safe area or  keyboard
///  	- or following the contents
///  - When following contents, we use a transform to move the wrapper view to the
///  	correct position in the scrollview.
///  - We adjust the contentInset.bottom to make sure that our footer view is taken into
///  	account when scrolling.
public final class StickyFooterView: UIView {
	/// the state of our sticking
	public enum State {
		case followingContent /// we're not sticking to anything
		case stickingToBottomOfSafeArea /// sticking to the safe area
		case stickingToBottomOfKeyboard /// sticking to the keyboard

		/// true if we're sticking to something
		public var isSticking: Bool {
			switch self {
				case .followingContent: return false
				case .stickingToBottomOfSafeArea: return true
				case .stickingToBottomOfKeyboard: return true
			}
		}
	}

	/// the sticky footer mode
	public enum Mode: CaseIterable {
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

	/// determines how the scrollable content is aligned when it's not scrollable,
	/// alignment is done by modifying `contentInset.top`
	public enum ScrollableContentVerticalAlignment: CaseIterable {
		case top /// content is aligned to top
		case center /// content is aligned in the middle
		case bottom /// content is aligned to the bottom
	}

	/// the background color of the sticky footer, including safeArea, when sticked to the bottom of the table view.
	public var stickingBackgroundColor: UIColor? {
		didSet {
			reallyUpdateLayout(canAnimate: false)
		}
	}

	/// the blur effect to apply when the sticky footer has sticked to the bottom of the table view.
	/// Defaults to `UIBlurEffect(style: .systemChromeMaterial)` before iOS 26,
	/// to `nil` on iOS 26 and higher.
	public var stickingBlurEffect: UIBlurEffect? {
		didSet {
			reallyUpdateLayout(canAnimate: false)
		}
	}

	/// if true, on iOS 26 this will apply a scroll edge element to the tableview behind
	/// the sticky footer view. Defaults to `true` on iOS26+, `false` otherwise.
	///
	/// Note, UIKit currently only uses this if there isn't already another edge, such as a
	/// tab bar. If there is, this edge will sadly be ignored.
	public var stickingUsesScrollEdgeElement = false {
		didSet {
			guard stickingUsesScrollEdgeElement != oldValue else { return }
			updateScrollEdgeElementContainerInteraction(shouldShow: state.isSticking)
		}
	}

	/// holds if we are sticking the bottom view to something and if so to what.
	/// Use `footerStickinessChangedCallback` to be notified when this changes.
	public private(set) var state = State.followingContent {
		didSet {
			guard state != oldValue else { return }
			ensureIsAtFront {}
			stateDidChangeCallback?()
		}
	}

	/// will be called when `stickingState` changes
	public var stateDidChangeCallback: (() -> Void)?

	/// the mode to use for the sticky footer. Changes can be animated when wrapped in an animation block.
	public var mode: Mode = .automatic {
		didSet {
			guard mode != oldValue else { return }
			reallyUpdateLayout(canAnimate: false)
		}
	}

	/// if true, we avoid the keyboard and we see the top of the keyboard as where to stick the footer view to.
	/// Changes can be animated when wrapped in an animation block.
	public var avoidsKeyboard = true {
		didSet {
			guard avoidsKeyboard != oldValue else { return }
			updateKeyboardTracking()
			reallyUpdateLayout(canAnimate: false)
		}
	}

	/// the spacing we keep on top of the keyboard to the contents (the sticky footer or the contents of the table view).
	/// Changes can be animated when wrapped in an animation block.
	public var spacingToKeyboard = CGFloat(0) {
		didSet {
			guard spacingToKeyboard != oldValue else { return }
			reallyUpdateLayout(canAnimate: false)
		}
	}

	/// the required height for the content. If sticking a button to the bottom of the safe area or keyboard
	/// would result into less height available for the actual table view content than this value, we won't
	/// stick the button.
	/// Changes can be animated when wrapped in an animation block.
	public var requiredAvailableScrollableContentHeight = CGFloat(0) {
		didSet {
			guard requiredAvailableScrollableContentHeight != oldValue else { return }
			reallyUpdateLayout(canAnimate: false)
		}
	}

	/// determines how the scroll views content (the rows and headers etc) is aligned when it fits and thus is not scrollable.
	/// Alignment is done by modifying `contentInset.top`
	public var fittingScrollableContentVerticalAlignment = ScrollableContentVerticalAlignment.top {
		didSet {
			guard fittingScrollableContentVerticalAlignment != oldValue else { return }
			reallyUpdateLayout(canAnimate: false)
		}
	}

	// MARK: - Internals

	internal init() {
		if #available(iOS 26, *) {
			stickingUsesScrollEdgeElement = true
		} else {
			stickingUsesScrollEdgeElement = false

			if #available(iOS 13, *) {
				stickingBlurEffect = UIBlurEffect(style: .systemChromeMaterial)
			} else {
				stickingBlurEffect = UIBlurEffect(style: .light)
			}
		}

		super.init(frame: .zero)

		wrapperView.preservesSuperviewLayoutMargins = true
		preservesSuperviewLayoutMargins = true

		wrapperView.addSubview(blurView, filling: .superview)
		constraintsList = wrapperView.addSubview(self, filling: .superview)
	}

	@available(*, unavailable)
	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	/// should be called by the scrollview (subclass) to add the sticky footer to itself
	internal func addToScrollView(_ scrollView: UIScrollView) {
		self.scrollView = scrollView

		wrapperViewConstraintsList = scrollView.addSubview(wrapperView, pinning: .bottom, to: .bottom, of: .scrollFrame, horizontally: .filling(.scrollFrame))

		updateKeyboardTracking()
		updateScrollEdgeElementContainerInteraction(shouldShow: state.isSticking)
		reallyUpdateLayout(canAnimate: false)
	}

	/// should be called by the scrollview (subclass) in all methods that change the order of views,
	/// .e.g `addSubview()`. Implementation should wrap the super call in this method, like:
	/// ```
	/// 	public override func addSubview(_ subview: UIView) {
	///			stickyFooterView.ensureIsAtFront {
	///				super.addSubview(subview)
	///			}
	/// 	}
	///```
	internal func ensureIsAtFront(callback: () -> Void) {
		guard
			let scrollView,
			ensureAtFrontCount == 0
		else {
			return callback()
		}
		
		ensureAtFrontCount += 1
		defer { ensureAtFrontCount -= 1 }

		let hasStickyFooterView = (wrapperView.superview != nil)
		callback()

		guard hasStickyFooterView == true else { return }

		// if we're not sticking to the bottom, we want to be behind the first scroll pocket or scroll indicator
		if state.isSticking == false,
		   let index = scrollView.subviews.firstIndex(where: { NSStringFromClass($0.classForCoder).contains(Self.uiScrollSubview) }) {
			let subviewToInsertBelow = scrollView.subviews[index]
			let subview = index > 0 ?scrollView : subviews[0]
			if subview !== wrapperView {
				scrollView.insertSubview(wrapperView, belowSubview: subviewToInsertBelow)
			}
		} else {
			if scrollView.subviews.last != wrapperView {
				scrollView.bringSubviewToFront(wrapperView)
			}
		}
	}

	/// should be called by the scrollview (subclass) before it's updating content, e.g. in `beginUpdates()`
	internal func willBeginContentUpdate(withAnimation animated: Bool = true) {
		isUpdatingScrollableContentCount += 1

		if animated == true {
			animationCount += 1
		}
	}

	/// should be called by the scrollview (subclass) when updating content is done, e.g. in `endUpdates()`
	internal func didEndContentUpdate() {
		isUpdatingScrollableContentCount -= 1

		if isUpdatingScrollableContentCount == 0 {
			if animationCount > 0 {
				updateLayout()
			}
			animationCount = 0
		}
	}

	/// should be called by the table view when it's inside one of the update methods, e.g. Wrap the `super.` call into this method.
	internal func trackTableViewUpdate(animation: UITableView.RowAnimation, _ callback: () -> Void) {
		willBeginContentUpdate(withAnimation: animation != .none)
		callback()
		didEndContentUpdate()
	}

	/// should be called by the collection view when it's inside one of the update methods, e.g. Wrap the `super.` call into this method.
	internal func trackCollectionViewUpdate(_ callback: () -> Void) {
		willBeginContentUpdate()
		callback()
		didEndContentUpdate()
	}

	/// should be called by the scrollview (subclass) when the contentSize __changes__.
	internal func scrollViewDidChangeContentSize() {
		// if we are in an animated update, we'll wait until the
		// end of the update block, which will fire off an update anyways -
		// this ensure that the table view updates its `frameLayoutGuide`
		// correctly.
		if animationCount == 0 {
			updateLayout()
		}
	}

	/// should be called by the scrollview (subclass) in layoutSubviews()
	internal func scrollViewDidLayoutSubviews() {
		reallyUpdateLayout()
	}

	/// should be called by the scrollview (subclass) when the bounds __changes__ or the insets changes.
	internal func scrollViewDidChangeBoundsOrInsets() {
		updateLayout()
	}

	// MARK: - Privates

	/// subclasses to be able to properly debug the view hierarchy by giving views an
	/// easy to recognize name
	private final class StickyFooterWrapperView: UIView {}

	private weak var scrollView: UIScrollView?
	private var animationCount = 0
	private var updateLayoutCount = 0
	private var isUpdatingScrollableContentCount = 0
	private var ensureAtFrontCount = 0
	private var constraintsList: ConstraintsList!
	private var wrapperViewConstraintsList: ConstraintsList?
	private var keyboardTrackerCancellable: KeyboardTracker.Cancellable?

	private let wrapperView = StickyFooterWrapperView()
	private let blurView = UIVisualEffectView()

	private var scrollEdgeElementContainerInteractionInternal: Any?

	private static let uiScrollSubview = "U*I*S*c*r*o*l*l".replacingOccurrences(of: "*", with: "")

	/// Updates layout with animation if `animationCount > 0`
	private func updateLayout() {
		if animationCount > 0 {
			UIView.animate(withDuration: 0.25, delay: 0, options: [.allowUserInteraction, .beginFromCurrentState]) {
				self.reallyUpdateLayout()
				self.wrapperView.layoutIfNeeded()
			}
		} else {
			reallyUpdateLayout()
		}
	}

	/// The real work horse - updates the layout by calculating where we should be and then updating the scroll view
	/// and the wrapper and footer views constraint insets.
	private func reallyUpdateLayout(canAnimate: Bool = true) {
		guard let scrollView else { return }
		// this method is not re-entrant to avoid layout loops, so check for that.
		guard updateLayoutCount == 0 else { return }
		updateLayoutCount += 1
		defer { updateLayoutCount -= 1 }

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
		if avoidsKeyboard == true && KeyboardTracker.shared.isKeyboardVisible == true {
			keyboardAdjustmentBottomInset = KeyboardTracker.shared.effectiveContentInset(
				view: scrollView,
				ignoreHierarchyTransforms: true,
				ignoreViewScrollOffset: true
			).bottom
			bottomInset = max(keyboardAdjustmentBottomInset, scrollView.safeAreaInsets.bottom)
			isUsingKeyboardAsBottomBoundary = (keyboardAdjustmentBottomInset > scrollView.safeAreaInsets.bottom)

			if isUsingKeyboardAsBottomBoundary == true {
				keyboardAdjustmentBottomInset += spacingToKeyboard
				bottomInset += spacingToKeyboard
			}
		} else {
			bottomInset = scrollView.safeAreaInsets.bottom
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
			let contentBottomY = roundToPoints(scrollView.contentSize.height - scrollView.contentOffset.y - scrollView.contentInset.top + topInsetToUse)
			let visibleScrollFrameY = roundToPoints(scrollView.bounds.height - bottomInset - bounds.height)

			// calculate how much translation we need to follow the contents and check if we actually
			// fit if we would stick
			let neededTranslationToFollowContents = roundToPoints(visibleScrollFrameY - contentBottomY + (isUsingKeyboardAsBottomBoundary == true ? 0 : bottomInset))
			let hasEnoughSpaceForContent = scaleToPixels(visibleScrollFrameY - scrollView.safeAreaInsets.top) >= scaleToPixels(requiredAvailableScrollableContentHeight)
			let hasContentsPastBottom = (scaleToPixels(contentBottomY) >= scaleToPixels(visibleScrollFrameY))

			var layout = Layout()
			switch mode {
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
			layout.bottomInset = bounds.height
			var baseBottomContentInset = CGFloat(0)
			if isUsingKeyboardAsBottomBoundary == true {
				// if we are using the keyboard as bottom boundary, adjust the content
				// inset accordingly
				baseBottomContentInset = keyboardAdjustmentBottomInset - scrollView.safeAreaInsets.bottom
				layout.bottomInset += baseBottomContentInset
			}

			// calculate scroll indicator bottom inset
			if layout.isSticking == true {
				layout.scrollIndicatorBottomInset = layout.bottomInset
			} else {
				layout.scrollIndicatorBottomInset = baseBottomContentInset
			}

			// calculate top inset
			let availableContentHeight = scrollView.bounds.height - scrollView.safeAreaInsets.top - scrollView.safeAreaInsets.bottom - layout.bottomInset
			let leftOverSpace = max(0, availableContentHeight - scrollView.contentSize.height)
			switch fittingScrollableContentVerticalAlignment {
				case .top: layout.topInset = 0
				case .center: layout.topInset = roundToPoints(leftOverSpace * 0.5)
				case .bottom: layout.topInset = roundToPoints(leftOverSpace)
			}

			if layout.isSticking == false {
				// ensure translation makes sense by adjusting for the top inset
				switch mode {
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
			let defaultIsStickingAndCanChangeSticking = switch mode {
				case .automatic: false
				case .alwaysOnBottom: false
				case .alwaysBelowContent: false
				case .onBottomWhenScrolledOutOfView: false
				case .onBottomWhenNotOverlappingContent: true
			}

			// if we have a top we might actually need to change our sticking,
			// because we calculate the layout without top inset first. So,
			// check if our sticking changes when using a top inset and if so,
			// use the new layout.
			let newLayout = determineLayout(topInsetToUse: layout.topInset)
			if newLayout.isSticking != defaultIsStickingAndCanChangeSticking {
				layout = newLayout
			}
		}

		// set all layout by using a helper function that first checks for actual differences.
		if let wrapperViewConstraintsList {
			set(wrapperViewConstraintsList, \.insets.bottom, to: layout.wrapperViewBottomInset)
		}
		set(constraintsList, \.insets.bottom, to: layout.footerViewBottomInset)
		set(scrollView, \.contentInset.bottom, to: layout.bottomInset)
		set(scrollView, \.contentInset.top, to: layout.topInset)

		// if we change this, we want to do it with animation so that it smoothly transitions
		if UIView.inheritedAnimationDuration == 0,
		   window != nil,
			scaleToPixels(scrollView.verticalScrollIndicatorInsets.bottom) !=
			scaleToPixels(layout.scrollIndicatorBottomInset) {
			UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
				scrollView.verticalScrollIndicatorInsets.bottom = layout.scrollIndicatorBottomInset
			})
		} else {
			set(scrollView, \.verticalScrollIndicatorInsets.bottom, to: layout.scrollIndicatorBottomInset)
		}

		wrapperView.transform = CGAffineTransform(translationX: 0, y: -layout.translation)

		// update our background: if we are sticky we show the background (effect, color, scroll edge),
		// if not, we remove the backgrounds.
		let updates = { [self] in
			blurView.effect = layout.isSticking ? stickingBlurEffect : nil
			wrapperView.backgroundColor = layout.isSticking ? stickingBackgroundColor : nil
			updateScrollEdgeElementContainerInteraction(shouldShow: layout.isSticking)
		}

		if canAnimate == true && state.isSticking != layout.isSticking && window != nil {
			UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: updates)
		} else {
			updates()
		}

		// update our local state
		if layout.isSticking == true {
			state = (isUsingKeyboardAsBottomBoundary == true ? .stickingToBottomOfKeyboard : .stickingToBottomOfSafeArea)
		} else {
			state = .followingContent
		}

		// if we are in an animation block, do an actual layout pass,
		// so our layout is updated with animation
		if UIView.inheritedAnimationDuration > 0 {
			scrollView.layoutIfNeeded()
		}
	}

	/// start tracking keyboard if we need or stops it.
	private func updateKeyboardTracking() {
		if avoidsKeyboard == true {
			if keyboardTrackerCancellable == nil {
				keyboardTrackerCancellable = KeyboardTracker.shared.addObserver { [weak self] _ in
					guard let self else { return }

					reallyUpdateLayout(canAnimate: true)
					scrollView?.layoutIfNeeded()
				}
			}
		} else {
			if let keyboardTrackerCancellable {
				KeyboardTracker.shared.removeObserver(keyboardTrackerCancellable)
			}
			keyboardTrackerCancellable = nil
		}
	}

	/// adds an scroll edge if needed or removes it.
	private func updateScrollEdgeElementContainerInteraction(shouldShow: Bool) {
		guard
			#available(iOS 26, *),
			let scrollView
		else {
			return
		}

		if stickingUsesScrollEdgeElement == true && shouldShow == true {
			if scrollEdgeElementContainerInteractionInternal == nil {
				let interaction = UIScrollEdgeElementContainerInteraction()
				interaction.scrollView = scrollView
				interaction.edge = .bottom
				addInteraction(interaction)
				scrollEdgeElementContainerInteractionInternal = interaction
			}
		} else if let interaction = scrollEdgeElementContainerInteractionInternal as? UIScrollEdgeElementContainerInteraction {
			removeInteraction(interaction)
			scrollEdgeElementContainerInteractionInternal = nil
		}
	}
}

// MARK: -

public extension StickyFooterView {
	protocol Provider {
		var stickyFooterView: StickyFooterView { get }
	}
}
