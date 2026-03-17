//
//  StickyTableViewController.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 16/03/2026.
//

import UIKit

class StickyTableViewController: UIViewController {
	var itemsToShow = 20

	var tableView: StickyBottomFooterTableView! {
		return view as? StickyBottomFooterTableView
	}

	@objc private func hideKeyboard(_ sender: Any) {
		view.window?.endEditing(true)
	}

	override func loadView() {
		view = StickyBottomFooterTableView(frame: .zero, style: .insetGrouped)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		tableView.dataSource = self
		tableView.stickyFooterMode = .automatic
		tableView.stickyFooterSpacingToKeyboard = 8
		tableView.stickyFooterRequiredAvailableContentHeight = 0
		tableView.keyboardDismissMode = .interactive

		let button = UIButton()
		if #available(iOS 26, *) {
			button.configuration = .prominentGlass()
		} else {
			button.configuration = .bordered()
		}

		button.configuration?.title = "Test"
		button.configuration?.buttonSize = .large

		let hideKeyboardButton = UIButton()
		hideKeyboardButton.configuration = .plain()
		hideKeyboardButton.configuration?.image = UIImage(systemName: "keyboard.chevron.compact.down")
		hideKeyboardButton.addTarget(self, action: #selector(hideKeyboard(_:)), for: .touchUpInside)
		hideKeyboardButton.sizeToFit()

		let textField = UITextField()
		textField.borderStyle = .roundedRect
		textField.placeholder = "Tap to show keyboard"
		textField.rightView = hideKeyboardButton
		textField.rightViewMode = .whileEditing
		navigationItem.titleView = textField

		let deferredMenu = UIDeferredMenuElement.uncached { provider in
			let countsToShow = [0, 1, 2, 5, 20]
			let countMenuItems = countsToShow.map { count in
				return UIAction(title: "Show \(count) \(count == 1 ? "Item" : "Items")", state: (count == self.itemsToShow ? .on : .off), handler: { _ in
					self.itemsToShow = count
					self.tableView.reloadSections(IndexSet(integer: 0), with: .fade)
				})
			}

			let modeMenuItems = StickyBottomFooterTableView.StickyFooterMode.allCases.map { mode in
				return UIAction(title: String(describing: mode), state: (mode == self.tableView.stickyFooterMode ? .on : .off), handler: { _ in
					UIView.animate(withDuration: 0.25) {
						self.tableView.stickyFooterMode = mode
					}
				})
			}

			let avoidKeyboardMenuItem = UIAction(title: "Avoids Keyboard", state: (self.tableView.stickyFooterAvoidsKeyboard ? .on : .off), handler: { _ in
				UIView.animate(withDuration: 0.25) {
					self.tableView.stickyFooterAvoidsKeyboard.toggle()
				}
			})

			let alignmentMenuItems = StickyBottomFooterTableView.TableContentAlignment.allCases.map { mode in
				return UIAction(title: String(describing: mode), state: (mode == self.tableView.stickyFooterTableContentAlignment ? .on : .off), handler: { _ in
					UIView.animate(withDuration: 0.25) {
						self.tableView.stickyFooterTableContentAlignment = mode
					}
				})
			}

			provider ([
				UIMenu(title: "Number of Items to Show", children: countMenuItems),
				UIMenu(title: "Content Alignment", children: alignmentMenuItems),
				UIMenu(title: "Mode", options: .displayInline, children: modeMenuItems),
				avoidKeyboardMenuItem,
			])
		}


		if #available(iOS 16, *) {
			navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), menu: UIMenu(children: [deferredMenu]))
		}

		tableView.stickyFooterView.addSubview(button, filling: .superview, insets: .horizontal(80).with(bottom: 16))
	//	view.addSubview(UITextField(backgroundColor: .green.withAlphaComponent(0.5)).constrain(height: 40), pinnedTo: .top, of: .safeArea)
	}
}

extension StickyTableViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return itemsToShow
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
		cell.textLabel?.text = "Row \(indexPath.row)"
		cell.imageView?.image = UIImage(systemName: "star.fill")
		return cell
	}
}

extension StickyTableViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

	}
}
