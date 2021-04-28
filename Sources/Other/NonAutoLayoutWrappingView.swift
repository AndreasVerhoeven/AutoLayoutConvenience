//
//  NonAutoLayoutWrappingView.swift
//  AutoLayoutConvenience
//
//  Created by Andreas Verhoeven on 28/04/2021.
//

import UIKit

/// This view is used to stop AutoLayout constraints from taking effect on it.
/// Useful for example wrapping an UIImageView, which can mess up auto-layout
/// because of it intrinsicSize.
class NonAutoLayoutWrappingView: UIView {

	/// The view to wrap: will fill the current bounds completely
	var view: UIView? {
		didSet {
			guard view !== oldValue else {return}
			oldValue?.removeFromSuperview()
			view.map {addSubview($0)}
		}
	}

	/// Creates a `NonAutoLayoutWrappingView` by wrapping view
	init(view: UIView? = nil) {
		self.view = view
		super.init(frame: .zero)
		view.map { addSubview($0) }
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
	}

	// MARK: - UIView
	override func layoutSubviews() {
		super.layoutSubviews()

		let size = bounds.size
		view?.bounds = CGRect(origin: .zero, size: size)
		view?.center = CGPoint(x: size.width * 0.5, y: size.height * 0.5)
	}
}
