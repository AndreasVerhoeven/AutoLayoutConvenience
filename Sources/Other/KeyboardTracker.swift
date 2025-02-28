//
//  KeyboardTracker.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 26/07/2021.
//

import UIKit

/// Tracks keyboard notifications
@objcMembers class KeyboardTracker: NSObject, @unchecked Sendable {
	static let didUpdateNotification = Notification.Name(rawValue: "KeyboardTracker.DidUpdateNotification")
	typealias Callback = (KeyboardTracker) -> Void

	static let shared = KeyboardTracker()

	private(set) var isKeyboardVisible = false
	private(set) var animationCurve = UIView.AnimationCurve.easeInOut
	private(set) var animationDuration = TimeInterval(0)
	private(set) var isInCallbackCount = 0

	var keyboardScreenFrame: CGRect {
		var keyboardScreenFrame = storedKeyboardScreenFrame
		keyboardScreenFrame.origin.y += effectiveInteractiveDismissalOffset
		return keyboardScreenFrame
	}

	func trackInteractiveKeyboardDismissal(in scrollView: UIScrollView) {
		scrollView.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
	}

	func stopTrackingInteractiveKeyboardDismissal(for scrollView: UIScrollView) {
		scrollView.panGestureRecognizer.removeTarget(self, action: #selector(handlePan(_:)))
	}

	var animationCurveAnimationOptions: UIView.AnimationOptions {
		return UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue) << 16)
	}

	private var observers = [UUID: Callback]()
	private var lastKeyboardFrameWhenVisible = CGRect.zero

	struct Cancellable: @unchecked Sendable {
		weak var tracker: KeyboardTracker?
		let uuid = UUID()

		func cancel() {
			tracker?.removeObserver(self)
		}
	}

	override init() {
		super.init()
		let center = NotificationCenter.default
		center.addObserver(self, selector: #selector(keyboardShown(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
		center.addObserver(self, selector: #selector(keyboardHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
		center.addObserver(self, selector: #selector(keyboardChangeFrame(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)

		UIScrollView.swizzleKeyboardDismissModeIfNeeded()
	}

	func perform(_ changes: @escaping () -> Void) {
		if isInCallbackCount > 0 && animationDuration > 0 {
			UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurveAnimationOptions, animations: changes)
		} else {
			changes()
		}
	}

	// pass return value to removeObserver: to remove the observer or call .cancel() on it
	func addObserver(_ callback: @escaping Callback) -> Cancellable {
		let cancellable = Cancellable(tracker: self)
		observers[cancellable.uuid] = callback
		return cancellable
	}

	func removeObserver(_ cancellable: Cancellable) {
		observers.removeValue(forKey: cancellable.uuid)
	}

	// MARK: - Input
	@objc private func handlePan(_ gestureRecognizer: UIPanGestureRecognizer) {
		guard let scrollView = gestureRecognizer.view as? UIScrollView else { return }

		switch gestureRecognizer.state {
			case .possible:
				break

			case .began:
				switch scrollView.keyboardDismissMode {
					case .interactive, .interactiveWithAccessory:
						currentlyTrackingPanGestureRecognizer = gestureRecognizer

					case .none, .onDrag, .onDragWithAccessory:
						currentlyTrackingPanGestureRecognizer = nil

					@unknown default:
						break
				}

			case .changed:
				if currentlyTrackingPanGestureRecognizer != nil {
					let pointInScreen = gestureRecognizer.location(in: nil)
					let newKeyboardInteractiveDismissalOffset = max(0, pointInScreen.y - storedKeyboardScreenFrame.minY)
					if keyboardInteractiveDismissalOffset != newKeyboardInteractiveDismissalOffset {
						notifyObservers()
					}
				}

			case .ended, .cancelled, .failed:
				if currentlyTrackingPanGestureRecognizer != nil {
					keyboardInteractiveDismissalOffset = 0
					currentlyTrackingPanGestureRecognizer = nil
				}

			@unknown default:
				break
		}
	}


	// MARK: - Privates
	private var currentlyTrackingPanGestureRecognizer: UIPanGestureRecognizer?
	private var keyboardInteractiveDismissalOffset = CGFloat(0)
	private(set) var storedKeyboardScreenFrame = CGRect.zero

	private var effectiveInteractiveDismissalOffset: CGFloat {
		guard let currentlyTrackingPanGestureRecognizer else { return 0 }
		switch currentlyTrackingPanGestureRecognizer.state {
			case .possible: return 0
			case .began: return 0
			case .changed: return keyboardInteractiveDismissalOffset
			case .ended: return 0
			case .cancelled: return 0
			case .failed: return 0
			@unknown default: return 0
		}
	}

	private func notifyObservers() {
		NotificationCenter.default.post(name: Self.didUpdateNotification, object: self)
		let originalObservers = observers
		originalObservers.forEach { $0.value(self) }
	}

	// MARK: Notifications
	@objc private func keyboardShown(_ notification: Notification) {
		isKeyboardVisible = true
		keyboardChangeFrame(notification)
	}

	@objc private func keyboardHidden(_ notification: Notification) {
		isKeyboardVisible = false
		keyboardChangeFrame(notification)
	}

	@objc private func keyboardChangeFrame(_ notification: Notification) {
		animationCurve = UIView.AnimationCurve(rawValue: (notification.userInfo?[UIResponder.keyboardAnimationCurveUserInfoKey] as? Int) ?? 0) ?? .easeInOut
		animationDuration = (notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? TimeInterval) ?? 0
		storedKeyboardScreenFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero

		if currentlyTrackingPanGestureRecognizer != nil && keyboardInteractiveDismissalOffset != effectiveInteractiveDismissalOffset {
			if storedKeyboardScreenFrame.height > 0 {
				let percentage = keyboardInteractiveDismissalOffset / storedKeyboardScreenFrame.height
				animationDuration *= percentage
				animationCurve = .easeInOut
			}
		}

		if notification.name == UIResponder.keyboardWillHideNotification {
			let oldFrame = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
			let newFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero

			// we sometimes gets the willHide notification twice: make sure we ignore the second one
			if oldFrame.height != newFrame.height {
				lastKeyboardFrameWhenVisible = oldFrame
			}
		} else if isKeyboardVisible == true {
			lastKeyboardFrameWhenVisible = storedKeyboardScreenFrame
		}

		isInCallbackCount += 1
		notifyObservers()
		isInCallbackCount -= 1
	}
}
