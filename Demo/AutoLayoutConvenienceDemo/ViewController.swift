//
//  ViewController.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 28/04/2021.
//

import UIKit

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
	}
}

