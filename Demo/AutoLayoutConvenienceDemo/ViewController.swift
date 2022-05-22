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
		
//		let x = UIView(backgroundColor: .red)
//		let label = UILabel(text: "bla")
//		view.addSubview(label, pinnedTo: .bottom, of: .safeArea, horizontally: .center)
//		
//		UIView.if(.verticalRegular) {
//			UIView.if(view: label, is: .width(is: .atLeast(100))) {
//				self.view.addSubview(x.constrain(widthAndHeight: 100), centeredIn: .superview)
//			} else: {
//				self.view.addSubview(x.constrain(widthAndHeight: 20), centeredIn: .superview)
//			}
//		} else: {
//			self.view.addSubview(x.constrain(widthAndHeight: 50), pinning: .topCenter, to: .topCenter, of: .safeArea)
//		}.withoutCoalescing()//.animateChanges().withoutCoalescing()
//		
//		DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
//			UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState]) {
//				label.text = "b la vfs fvdv dv dvd vdv"
//				self.view.layoutIfNeeded()
//			}
//		})

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
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		view.firstScrollableView?.flashScrollIndicators()
	}
}
