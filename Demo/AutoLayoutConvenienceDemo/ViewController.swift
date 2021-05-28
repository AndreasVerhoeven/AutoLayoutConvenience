//
//  ViewController.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 28/04/2021.
//

import UIKit

class X: UIView {
	override func sizeThatFits(_ size: CGSize) -> CGSize {
		return CGSize(width: 20, height: 30)
	}
}

class ViewController: UIViewController {
	override func viewDidLoad() {
		super.viewDidLoad()

		let demoView = DemoView()
		demoView.actionButton.addAction(UIAction(handler: { _ in
			demoView.setSubTitleAnimated(String(repeating: demoView.subLabel.text ?? "", count: 2))
		}), for: .touchUpInside)
		demoView.cancelButton.addAction(UIAction(handler: { _ in
			demoView.setSubTitleAnimated(String(repeating: "Sub label with a lot of text. ", count: 10))
		}), for: .touchUpInside)

		view.addSubview(demoView, filling: .superview)

		print(X().systemLayoutSizeFitting(CGSize(width: 100, height: 100)))
	}
}

