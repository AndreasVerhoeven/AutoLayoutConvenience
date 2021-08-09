//
//  FillingViewController.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 29/07/2021.
//

import UIKit

class FillingViewController: BaseTableViewController {
	@IBOutlet var headerView: UIView!
	var currentView = UIView()

	func update(animated: Bool) {
		currentView.removeFromSuperview()
		headerView.directionalLayoutMargins = .all(16)
		headerView.addSubview(currentView, filling: .layoutMargins)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		currentView.backgroundColor = .red
		update(animated: false)
	}
}
