//
//  UIView+NegativeLayoutGuides.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 03/05/2023.
//

import UIKit

extension UIView {
	/// A collection of custom layout guides that cover the area excluded of the safe-area: the unsafe area,
	/// 4 sides that are not safe to show content in, since it might be obscured by device corners, notches
	/// or just not be visible at all.
	public var unsafeAreaLayoutGuides: ExcludedAreaLayoutGuides {
		ExcludedAreaLayoutGuides(view: self, layoutGuide: safeAreaLayoutGuide)
	}
	
	/// A collection of custom layout guides that cover the area excluded of the layoutMarginGuide: in
	/// a sense, these are the actual margins on all 4 sides.
	public var excludedByLayoutMarginsGuides: ExcludedAreaLayoutGuides {
		ExcludedAreaLayoutGuides(view: self, layoutGuide: layoutMarginsGuide)
	}
	
	/// A collection of custom layout guides that cover the inverse of the readable content guides: the unreadable area.
	/// 4 sides that are not okay to show readable content in, since they are outside of the readable content guide
	public var unreadableContentLayoutGuides: ExcludedAreaLayoutGuides {
		ExcludedAreaLayoutGuides(view: self, layoutGuide: readableContentGuide)
	}
	
	/// A struct that provides easy access to all 4 sides of the area that is excluded by another guide
	@MainActor public struct ExcludedAreaLayoutGuides {
		fileprivate weak var view: UIView?
		fileprivate var layoutGuide: UILayoutGuide
		
		/// The top layout guide that covers the area from top that is excluded by our layout guide
		public var top: UILayoutGuide {
			return retrieveOrCreate(name: "top") { view, guide in
				[
					guide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
					guide.topAnchor.constraint(equalTo: view.topAnchor),
					guide.bottomAnchor.constraint(equalTo: layoutGuide.topAnchor),
					guide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				]
			} ?? UILayoutGuide()
		}
		
		/// The leading layout guide that covers the area from top that is excluded by our layout guide
		public var leading: UILayoutGuide {
			return retrieveOrCreate(name: "leading") { view, guide in
				[
					guide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
					guide.topAnchor.constraint(equalTo: view.topAnchor),
					guide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
					guide.trailingAnchor.constraint(equalTo: layoutGuide.leadingAnchor),
				]
			} ?? UILayoutGuide()
		}
		
		/// The bottom layout guide that covers the area from top that is excluded by our layout guide
		public var bottom: UILayoutGuide {
			return retrieveOrCreate(name: "bottom") { view, guide in
				[
					guide.leadingAnchor.constraint(equalTo: view.leadingAnchor),
					guide.topAnchor.constraint(equalTo: layoutGuide.bottomAnchor),
					guide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
					guide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				]
			} ?? UILayoutGuide()
		}
		
		/// The trailing layout guide that covers the area from top that is excluded by our layout guide
		public var trailing: UILayoutGuide {
			return retrieveOrCreate(name: "trailing") { view, guide in
				[
					guide.leadingAnchor.constraint(equalTo: layoutGuide.trailingAnchor),
					guide.topAnchor.constraint(equalTo: view.topAnchor),
					guide.bottomAnchor.constraint(equalTo: view.bottomAnchor),
					guide.trailingAnchor.constraint(equalTo: view.trailingAnchor),
				]
			} ?? UILayoutGuide()
		}
		
		private func retrieveOrCreate(name: String, _ callback: (UIView, UILayoutGuide) -> [NSLayoutConstraint]) -> UILayoutGuide? {
			guard let view = view else { return nil }
			let identifier = "AutoLayoutConvenience.excluded.\(layoutGuide.identifier).\(name)"
			if let existingGuide = view.layoutGuides.first(where: { $0.identifier == identifier }) {
				return existingGuide
			} else {
				let guide = UILayoutGuide()
				guide.identifier = identifier
				view.addLayoutGuide(guide)
				NSLayoutConstraint.activate(callback(view, guide))
				return guide
			}
		}
	}
}
