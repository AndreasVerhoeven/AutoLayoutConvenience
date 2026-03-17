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

	func setItemsToShow(_ value: Int) {
		guard itemsToShow != value else { return }

		tableView.beginUpdates()
		if itemsToShow > value {
			let indexPaths = (value..<itemsToShow).map { IndexPath(row: $0, section: 0) }
			itemsToShow = value
			tableView.deleteRows(at: indexPaths, with: .fade)
		} else {
			let indexPaths = (itemsToShow..<value).map { IndexPath(row: $0, section: 0) }
			itemsToShow = value
			tableView.insertRows(at: indexPaths, with: .fade)
		}
		tableView.endUpdates()
	}

	override func loadView() {
		view = StickyBottomFooterTableView(frame: .zero, style: .insetGrouped)
	}

	override func viewDidLoad() {
		super.viewDidLoad()

		// create a button we want to show
		let button = UIButton()
		if #available(iOS 26, *) {
			button.configuration = .prominentGlass()
		} else {
			button.configuration = .bordered()
		}

		button.configuration?.title = "Test"
		button.configuration?.buttonSize = .large

		// configure table view
		tableView.dataSource = self
		tableView.stickyFooterMode = .automatic
		tableView.stickyFooterSpacingToKeyboard = 8
		tableView.stickyFooterRequiredAvailableContentHeight = 0
		tableView.keyboardDismissMode = .interactive
		tableView.stickyFooterView.addSubview(button, filling: .superview, insets: .horizontal(80).with(bottom: 16))

		// some ui to manipulate the table state
		let hideKeyboardButton = UIButton()
		hideKeyboardButton.configuration = .plain()
		hideKeyboardButton.configuration?.image = UIImage(systemName: "keyboard.chevron.compact.down")
		hideKeyboardButton.addTarget(self, action: #selector(hideKeyboard(_:)), for: .touchUpInside)
		hideKeyboardButton.sizeToFit()

		let textField = UITextField()
		textField.borderStyle = .roundedRect
		textField.placeholder = "Tap to Show Keyboard"
		textField.rightView = hideKeyboardButton
		textField.rightViewMode = .whileEditing
		navigationItem.titleView = textField

		if #available(iOS 17, *) {
			let deferredMenu = UIDeferredMenuElement.uncached { provider in
				let countsButtonMenu = UIMenu(options: .displayInline, children: [
					UIAction(image: UIImage(systemName: "minus"), attributes: .keepsMenuPresented, handler: { _ in
						self.setItemsToShow(max(self.itemsToShow - 1, 0))
					}),
					UIAction(image: UIImage(systemName: "plus"), attributes: .keepsMenuPresented, handler: { _ in
						self.setItemsToShow(self.itemsToShow + 1)
					}),
				])
				countsButtonMenu.preferredElementSize = .small

				let countsToShow = [0, 1, 2, 5, 10, 15, 20]
				let countMenuItems = countsToShow.map { count in
					return UIAction(title: "\(count)", attributes: .keepsMenuPresented, handler: { _ in
						self.setItemsToShow(count)
					})
				}

				let countsMenu = UIMenu(
					title: "Number of Rows",
					image: UIImage(systemName: "list.number"),
					children: [
						UIMenu(options: .displayInline, children: [countsButtonMenu]),
						UIMenu(options: [.displayInline, .displayAsPalette], children: countMenuItems),
					]
				)

				let modeMenuItems = StickyBottomFooterTableView.StickyFooterMode.allCases.map { mode in
					return UIAction(title: String(describing: mode), state: (mode == self.tableView.stickyFooterMode ? .on : .off), handler: { _ in
						UIView.animate(withDuration: 0.25) {
							self.tableView.stickyFooterMode = mode
						}
					})
				}

				let avoidKeyboardMenuItem = UIAction(title: "Avoids Keyboard", image: UIImage(systemName: "keyboard"), state: (self.tableView.stickyFooterAvoidsKeyboard ? .on : .off), handler: { _ in
					UIView.animate(withDuration: 0.25) {
						self.tableView.stickyFooterAvoidsKeyboard.toggle()
					}
				})

				let alignmentMenu = UIMenu(
					title: "Alignment",
					image: UIImage(systemName: "gearshape"),
					//options: .displayInline,
					children: [
						UIAction(title: "Top", image: UIImage(systemName: "align.vertical.top"), attributes: .keepsMenuPresented, handler: { _ in
							UIView.animate(withDuration: 0.25) {
								self.tableView.stickyFooterTableContentAlignment = .top
							}
						}),
						UIAction(title: "Centre", image: UIImage(systemName: "align.vertical.center"), attributes: .keepsMenuPresented, handler: { _ in
							UIView.animate(withDuration: 0.25) {
								self.tableView.stickyFooterTableContentAlignment = .center
							}
						}),
						UIAction(title: "Bottom", image: UIImage(systemName: "align.vertical.bottom"), attributes: .keepsMenuPresented, handler: { _ in
							UIView.animate(withDuration: 0.25) {
								self.tableView.stickyFooterTableContentAlignment = .bottom
							}
						}),
					]
				)
				alignmentMenu.preferredElementSize = .medium

				provider ([
					countsMenu,
					alignmentMenu,
					avoidKeyboardMenuItem,
					UIMenu(title: "Footer Position", options: .displayInline, children: modeMenuItems),
				])
			}

			navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gearshape"), menu: UIMenu(children: [deferredMenu]))
		}
	}
}

extension StickyTableViewController: UITableViewDataSource {
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return itemsToShow
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "Cell") ?? UITableViewCell(style: .default, reuseIdentifier: "Cell")
		cell.textLabel?.text = "Row \(indexPath.row + 1)"
		cell.imageView?.image = UIImage(systemName: "star.fill")
		return cell
	}
}

extension StickyTableViewController: UITableViewDelegate {
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

	}
}
