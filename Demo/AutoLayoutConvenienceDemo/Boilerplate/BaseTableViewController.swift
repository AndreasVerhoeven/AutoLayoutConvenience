//
//  BaseTableViewController.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 29/07/2021.
//

import UIKit

class BaseTableViewController: UITableViewController {
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		guard let header = view as? UITableViewHeaderFooterView else { return }
		header.textLabel?.font = .preferredFont(forTextStyle: .headline)
		header.textLabel?.textColor = .label
		header.textLabel?.text = header.textLabel?.text?.lowercased().capitalized
	}
}
