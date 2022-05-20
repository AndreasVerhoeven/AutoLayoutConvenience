//
//  ViewController.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 28/04/2021.
//

import UIKit

class ViewController: UIViewController {
	var collection: ConstraintsListCollection!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		let x = UIView(backgroundColor: .red)

		view.if(is: .verticallyCompact) {
			self.view.addSubview(x.constrain(widthAndHeight: 100), centeredIn: .superview)
		} else: {
			self.view.addSubview(x.constrain(widthAndHeight: 50), pinning: .topCenter, to: .topCenter, of: .safeArea)
		}
		
		
		/*
		let demoView = DemoView()
		demoView.actionButton.addAction(UIAction(handler: { _ in
			demoView.setSubTitleAnimated(String(repeating: demoView.subLabel.text ?? "", count: 2))
		}), for: .touchUpInside)
		demoView.cancelButton.addAction(UIAction(handler: { _ in
			demoView.setSubTitleAnimated(String(repeating: "Sub label with a lot of text. ", count: 10))
		}), for: .touchUpInside)
		demoView.textField.addAction(UIAction(handler: { _ in
			demoView.endEditing(true)
		}), for: .editingDidEndOnExit)

		view.addSubview(UIView(backgroundColor: .red), filling: .keyboardFrame)
		view.addSubview(demoView, filling: .keyboardSafeArea)
		 */
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		view.firstScrollableView?.flashScrollIndicators()
	}
}
