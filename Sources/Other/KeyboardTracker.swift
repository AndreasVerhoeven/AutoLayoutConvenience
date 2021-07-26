//
//  KeyboardTracker.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 26/07/2021.
//

import UIKit

/// Tracks keyboard notifications
@objcMembers class KeyboardTracker: NSObject {
	static let updatedNotification = Notification.Name(rawValue: "kBunqKeyboardTrackerUpdatedNotification")
	typealias Callback = (KeyboardTracker) -> Void

	static let shared = KeyboardTracker()

	private(set) var isKeyboardVisible = false
	private(set) var keyboardScreenFrame = CGRect.zero
	private(set) var animationCurve = UIView.AnimationCurve.easeInOut
	private(set) var animationDuration = TimeInterval(0)
	private(set) var isInCallbackCount = 0

	var animationCurveAnimationOptions: UIView.AnimationOptions {
		return UIView.AnimationOptions(rawValue: UInt(animationCurve.rawValue) << 16)
	}

	private var observers = [UUID: Callback]()
	private var lastKeyboardFrameWhenVisible = CGRect.zero

	struct Cancellable {
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
	}

	static func ensureIsLoaded() {
		_ = shared
	}

	func perform(_ changes: @escaping () -> Void) {
		if isInCallbackCount > 0 && animationDuration > 0 {
			UIView.animate(withDuration: animationDuration, delay: 0, options: animationCurveAnimationOptions, animations: changes)
		} else {
			changes()
		}
	}

	// pass return value to removeObserver: to remove the observer
	func addObserver(_ callback: @escaping Callback) -> Cancellable {
		let cancellable = Cancellable(tracker: self)
		observers[cancellable.uuid] = callback
		return cancellable
	}

	func removeObserver(_ cancellable: Cancellable) {
		observers.removeValue(forKey: cancellable.uuid)
	}

	// MARK: - Privates
	private func notifyObservers() {
		NotificationCenter.default.post(name: Self.updatedNotification, object: self)
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
		keyboardScreenFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero

		if notification.name == UIResponder.keyboardWillHideNotification {
			let oldFrame = (notification.userInfo?[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
			let newFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero

			// we sometimes gets the willHide notification twice: make sure we ignore the second one
			if oldFrame.height != newFrame.height {
				lastKeyboardFrameWhenVisible = oldFrame
			}
		} else if isKeyboardVisible == true {
			lastKeyboardFrameWhenVisible = keyboardScreenFrame
		}

		isInCallbackCount += 1
		notifyObservers()
		isInCallbackCount -= 1
	}
}
