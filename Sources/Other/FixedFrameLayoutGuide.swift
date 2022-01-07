//
//  FixedFrameLayoutGuide.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 07/01/2022.
//

import UIKit

/// This is a UILayoutGuide that always takes up a fixed position in its owning view.
class FixedFrameLayoutGuide: UILayoutGuide {
	/// the frame we want to take up in our owning view
	public var frame: CGRect = .zero {
		didSet {
			guard oldValue != frame else { return }
			updateConstraints()
		}
	}
	
	/// convenience helper that sets the origin point
	public var point: CGPoint {
		get { frame.origin }
		set { frame.origin = newValue }
	}
	
	// convenience helper that sets the center
	public var center: CGPoint {
		get { CGPoint(x: frame.midX, y: frame.midY) }
		set { point = CGPoint(x: newValue.x - frame.width * 0.5, y: newValue.y - frame.height * 0.5) }
	}
	
	// convenenience helper that sets the size
	public var size: CGSize {
		get { frame.size }
		set { frame.size = newValue }
	}
	
	// MARK: - Privates
	private var leadingConstraint: NSLayoutConstraint?
	private var trailingConstraint: NSLayoutConstraint?
	private var topConstraint: NSLayoutConstraint?
	private var bottomConstraint: NSLayoutConstraint?
	
	private func updateConstraints() {
		if let view = owningView {
			var needsActivation = false
			if leadingConstraint == nil {
				leadingConstraint = leadingAnchor.constraint(equalTo: view.leadingAnchor)
				trailingConstraint = trailingAnchor.constraint(equalTo: view.trailingAnchor)
				topConstraint = topAnchor.constraint(equalTo: view.topAnchor)
				bottomConstraint = bottomAnchor.constraint(equalTo: view.bottomAnchor)
				needsActivation = true
			}
			
			leadingConstraint?.constant = -frame.minX
			trailingConstraint?.constant = frame.maxX
			topConstraint?.constant = -frame.minY
			bottomConstraint?.constant = frame.maxY
			
			if needsActivation == true {
				NSLayoutConstraint.activate([leadingConstraint!, trailingConstraint!, topConstraint!, bottomConstraint!])
			}
		} else {
			leadingConstraint = nil
			trailingConstraint = nil
			topConstraint = nil
			bottomConstraint = nil
		}
	}
	
	// MARK: - UILayoutGuide
	public override weak var owningView: UIView? {
		didSet {
			guard oldValue !== owningView else { return }
			updateConstraints()
		}
	}
}

