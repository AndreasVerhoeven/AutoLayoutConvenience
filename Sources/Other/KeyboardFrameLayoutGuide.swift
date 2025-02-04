//
//  KeyboardFrameLayoutGuide.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 09/08/2021.
//

import UIKit

/// This is a layout guide that equals the area covered by the keyboard.
/// Note: you usually use `UIView.keyboardFrameLayoutGuide`
public class KeyboardFrameLayoutGuide: UILayoutGuide {
	fileprivate static let identifier = "AutoLayoutConvenience.keyboardFrameLayoutGuide"
	private let keyboardTracker = KeyboardTracker.shared
	private var keyboardTrackingCancellable: KeyboardTracker.Cancellable?
	private var heightConstraint: NSLayoutConstraint?

	/// iff true, the whole view hierarchy will be invalidated on update - if false, only the owningView will be invalidated
	public var invalidatesLayoutInWholeHierarchy = true

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
		let newHeightConstraint = heightAnchor.constraint(equalToConstant: 0)
		heightConstraint = newHeightConstraint

		NSLayoutConstraint.activate([
			leadingAnchor.constraint(equalTo: owningView.leadingAnchor),
			trailingAnchor.constraint(equalTo: owningView.trailingAnchor),
			bottomAnchor.constraint(equalTo: owningView.bottomAnchor),
			newHeightConstraint,
		])
	}

	private func update(forceLayout: Bool = true) {
		guard let owningView = owningView else { return }

		let newBottomInset = max(effectiveContentInsets.bottom, 0)
		guard newBottomInset != heightConstraint?.constant ?? 0 else { return }
		keyboardTracker.perform {
			self.heightConstraint?.constant = newBottomInset
			guard forceLayout == true else { return }

			if self.invalidatesLayoutInWholeHierarchy  == true {
				owningView.forceLayoutInViewHierarchy()
			} else {
				owningView.setNeedsLayout()
				owningView.layoutIfNeeded()
			}
		}
	}

	private var effectiveContentInsets: UIEdgeInsets {
		guard let owningView = owningView else { return .zero }

		// we're only interested in vertical insets
		let boundsInScreenCoordinates = owningView.convert(owningView.bounds, to: nil)
		var keyboardScreenFrame = keyboardTracker.keyboardScreenFrame
		keyboardScreenFrame.origin.x = boundsInScreenCoordinates.minX
		keyboardScreenFrame.size.width = boundsInScreenCoordinates.width

		guard keyboardScreenFrame.isEmpty == false && keyboardScreenFrame.intersects(boundsInScreenCoordinates) == true else { return .zero }
		let keyboardHeightInView = max(boundsInScreenCoordinates.maxY - keyboardScreenFrame.minY, 0)
		return UIEdgeInsets(top: 0, left: 0, bottom: keyboardHeightInView, right: 0)
	}

	// MARK: - UILayoutGuide
	public override var owningView: UIView? {
		didSet {
			install()
			update()
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
	/// this is a layout guide that equals the area covered by the keyboard.
	var keyboardFrameLayoutGuide: KeyboardFrameLayoutGuide {
		if let existing = layoutGuides.first(where: { $0.identifier == KeyboardFrameLayoutGuide.identifier }) as? KeyboardFrameLayoutGuide {
			return existing
		}

		let layoutGuide = KeyboardFrameLayoutGuide()
		layoutGuide.identifier = KeyboardFrameLayoutGuide.identifier
		addLayoutGuide(layoutGuide)
		return layoutGuide
	}
}
