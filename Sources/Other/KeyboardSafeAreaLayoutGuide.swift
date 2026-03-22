//
//  KeyboardSafeAreaLayoutGuide.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 09/08/2021.
//

import UIKit

/// This is a Layout Guide that equals the `safeArea` minus the area taken up by the keyboard.
/// In short: it's the area not covered by the keyboard.
/// Note: You usually use `UIView.keyboardSafeAreaLayoutGuide`
public class KeyboardSafeAreaLayoutGuide: UILayoutGuide {
	fileprivate static let identifier = "AutoLayoutConvenience.KeyboardSafeAreaLayoutGuide"
	private let keyboardTracker = KeyboardTracker.shared
	private var keyboardTrackingCancellable: KeyboardTracker.Cancellable?
	private var bottomConstraint: NSLayoutConstraint?

	/// iff true, the whole view hierarchy will be invalidated on update - if false, only the owningView will be invalidated
	public var invalidatesLayoutInWholeHierarchy = true

	/// if true, we ignore any transforms in the view hierarchy
	public var ignoreHierarchyTransforms = true

	/// call this to ensure interactive keyboard dismissal is properly tracked
	public static func ensureInteractiveKeyboardDismissalTracking() {
		UIScrollView.swizzleKeyboardDismissModeIfNeeded()
	}

	// MARK: - Privates
	private func setup() {
		keyboardTrackingCancellable = keyboardTracker.addObserver { [weak self] _ in
			self?.update()
		}
	}

	private func install() {
		guard let owningView = owningView else { return }
		let newBottomConstraint = owningView.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: bottomAnchor, constant: 0)
		bottomConstraint = newBottomConstraint

		NSLayoutConstraint.activate([
			topAnchor.constraint(equalTo: owningView.safeAreaLayoutGuide.topAnchor),
			leadingAnchor.constraint(equalTo: owningView.safeAreaLayoutGuide.leadingAnchor),
			trailingAnchor.constraint(equalTo: owningView.safeAreaLayoutGuide.trailingAnchor),
			newBottomConstraint,
		])
	}

	private func update(forceLayout: Bool = true) {
		guard let owningView = owningView else { return }

		let newBottomInset = max(effectiveContentInsets.bottom - owningView.safeAreaInsets.bottom, 0)
		guard newBottomInset != bottomConstraint?.constant ?? 0 else { return }
		keyboardTracker.perform {
			self.bottomConstraint?.constant = newBottomInset
			guard forceLayout == true else { return }

			if self.invalidatesLayoutInWholeHierarchy  == true {
				owningView.forceLayoutInViewHierarchy()
			} else {
				owningView.setNeedsLayout()
				owningView.layoutIfNeeded()
			}
		}
	}

	private var owningBoundsInScreenCoordinates: CGRect {
		guard let owningView = owningView else { return .zero }

		return keyboardTracker.boundsInScreenCoordinates(
			view: owningView,
			ignoreHierarchyTransforms: ignoreHierarchyTransforms,
			ignoreViewScrollOffset: false)
	}

	private var effectiveContentInsets: UIEdgeInsets {
		guard let owningView else { return .zero }

		return keyboardTracker.effectiveContentInset(
			view: owningView,
			ignoreHierarchyTransforms: ignoreHierarchyTransforms,
			ignoreViewScrollOffset: false)
	}

	// MARK: - UILayoutGuide
	public override var owningView: UIView? {
		didSet {
			install()
			update(forceLayout: false)
		}
	}

	// MARK: - NSObject
	public override init() {
		super.init()
		setup()
	}

	public required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}

	deinit {
		keyboardTrackingCancellable?.cancel()
	}
}


public extension UIView {
	/// A layout guide for the area not covered by the keyboard, or the `safeArea` if the keyboard is not visible.
	var keyboardSafeAreaLayoutGuide: KeyboardSafeAreaLayoutGuide {
		if let existing = layoutGuides.first(where: { $0.identifier == KeyboardSafeAreaLayoutGuide.identifier }) as? KeyboardSafeAreaLayoutGuide {
			return existing
		}

		let layoutGuide = KeyboardSafeAreaLayoutGuide()
		layoutGuide.identifier = KeyboardSafeAreaLayoutGuide.identifier
		addLayoutGuide(layoutGuide)
		return layoutGuide
	}
}


public extension UIView {
	/// forces layout in the whole view hierarchy, upwards.
	func forceLayoutInViewHierarchy() {
		var possibleView: UIView? = self
		while let view = possibleView {
			view.setNeedsLayout()
			possibleView = view.superview
			if possibleView == nil {
				view.layoutIfNeeded()
			}
		}
	}
}
