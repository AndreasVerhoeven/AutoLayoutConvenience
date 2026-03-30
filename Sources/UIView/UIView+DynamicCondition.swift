//
//  UIView+DynamicCondition.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 30/03/2026.
//

import UIKit

public protocol DynamicallyConfigurableView: AnyObject {}

extension DynamicallyConfigurableView where Self: UIView {
	/// Configures a view dynamically: if the `condition`  changes, the callback will be called with the
	/// state of the condition and the view.
	///
	/// Do not retain the view inside the callbacks - it will be passed to you in the callbacks as an argument.
	///
	/// Parameters:
	/// 	- if condition: the condition that should trigger the callback
	/// 	- callback: the callback that will be called when the condition changes
	///
	/// Return:
	/// 	- `self` is returned, for easy chaining.
	@discardableResult public func configureDynamically(
		condition: UIView.Condition,
		callback: @escaping (_ matchesCondition: Bool, _ view: Self) -> Void
	) -> Self {
		return configureDynamically(as: UIView.self, condition: condition) { [weak self] matchesCondition, view in
			guard let self else { return }
			callback(matchesCondition, self)
		}
	}

	/// Configures a view dynamically: if the `condition` holds the `then` callback is called, otherwise `else`. The callbacks
	/// can be called multiple times during the life time of this view.
	///
	/// Do not retain the view inside the callbacks - it will be passed to you in the callbacks as an argument.
	///
	/// Parameters:
	/// 	- if condition: the condition that should trigger the `then` callback
	/// 	- then: the callback that will be called if the condition holds
	/// 	- else: the callback that will be called if the condition does not hold
	///
	/// Return:
	/// 	- `self` is returned, for easy chaining.
	@discardableResult public func configureDynamically(
		`if` condition: UIView.Condition,
		then: @escaping (Self) -> Void,
		else: @escaping (Self) -> Void
	) -> Self {
		return configureDynamically(condition: condition) { matchesCondition, view in
			if matchesCondition == true {
				then(view)
			} else {
				`else`(view)
			}
		}
	}

	/// Configures a key path of a view to a given value if the condition matches, otherwise to the other value
	///
	/// Parameters:
	/// 	- keyPath: the key path to configure
	/// 	- if condition: the condition to match against
	/// 	- to: the value set to key path if the condition matches
	/// 	- else: the alternative value set if the key path doesn't match
	///
	/// Return:
	/// 	- `self` is returned, for easy chaining.
	@discardableResult public func configure<T>(keyPath: ReferenceWritableKeyPath<Self, T>, if condition: UIView.Condition, to: T, else: T) -> Self {
		return configureDynamically(as: UIView.self, condition: .contentSizeCategoryIsNotAccessibility) { [weak self] matches, view in
			guard let self else { return }
			self[keyPath: keyPath] = matches ? to : `else`
		}
	}

	/// Configures a key path of a view to a given value if in normal content size mode, or to accessibility in accessibility content size mode.
	///
	/// Parameters:
	/// 	- keyPath: the key path to configure
	/// 	- to: the value set to key path if the in regular content size mode
	/// 	- accessibility: the alternative value to set in accessibility content size mode
	///
	/// Return:
	/// 	- `self` is returned, for easy chaining.
	@discardableResult public func configure<T>(keyPath: ReferenceWritableKeyPath<Self, T>, to: T, accessibility: T) -> Self {
		return configure(keyPath: keyPath, if: .contentSizeCategoryIsNotAccessibility, to: to, else: accessibility)
	}
}

extension UIView: DynamicallyConfigurableView {
	/// Hides this view if we are in accessibility content size mode.
	/// Returns `self` for easy chaining.
	@discardableResult public func hiddenInAccessibilityContentSizeMode() -> Self {
		return configureDynamically(condition: .contentSizeCategoryIsAccessibility) { matchesCondition, view in
			view.isHidden = matchesCondition
		}
	}

	/// Configures a view dynamically: if the `condition`  changes, the callback will be called with the
	/// state of the condition and the view.
	///
	/// Do not retain the view inside the callbacks - it will be passed to you in the callbacks as an argument.
	///
	/// Parameters:
	/// 	- as: the UIView subclass the view will be passed as in the callback
	/// 	- if condition: the condition that should trigger the callback
	/// 	- callback: the callback that will be called when the condition changes
	///
	/// Return:
	/// 	- `self` is returned, for easy chaining.
	@discardableResult fileprivate func configureDynamically<ViewType: UIView>(
		as: ViewType.Type,
		condition: UIView.Condition,
		callback: @escaping (_ matchesCondition: Bool, _ view: ViewType) -> Void
	) -> Self {
		let conditionList = DynamicCondition(condition: condition, view: self) { matches, view in
			guard let view = view as? ViewType else { return }
			callback(matches, view)
		}

		var lists = dynamicConditions ?? []
		lists.append(conditionList)
		dynamicConditions = lists

		conditionList.install()
		return self
	}

	/// gets the constraints list for this view
	fileprivate static var dynamicConditionListKey = 0
	fileprivate var dynamicConditions: [DynamicCondition]? {
		get { objc_getAssociatedObject(self, &Self.dynamicConditionListKey) as? [DynamicCondition] }
		set { objc_setAssociatedObject(self, &Self.dynamicConditionListKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
	}

	fileprivate class DynamicCondition: ConditionList<DynamicCondition.Item> {
		struct Item: UIView.Condition.ItemProvider {
			var id = UUID()
			var condition: UIView.Condition
		}

		init(condition: UIView.Condition, view: UIView, callback: @escaping (Bool, UIView) -> Void) {
			self.callback = callback
			super.init(view: view)
			items.append(Item(condition: condition))
		}

		fileprivate var callback: (Bool, UIView) -> Void
		fileprivate var conditionIsActive = false

		override func applyUpdates(_ activeItems: [Item], inactiveItems: [Item], view: UIView, animated: Bool) {
			conditionIsActive = (activeItems.isEmpty == false)
			callback(conditionIsActive, view)
		}
	}
}

extension UILabel {
	/// Sets the text alignment for this label in regular content-size mode and in accessibility size mode
	///
	/// Parameters:
	/// 	- alignment: the alignment to use in regular mode
	/// 	- accessibility: the alignment to use in accessibility mode
	///
	/// Return:
	/// 	- `self` is returned, for easy chaining.
	@discardableResult public func textAlignment(_ alignment: NSTextAlignment, accessibility: NSTextAlignment) -> Self {
		return configureDynamically(condition: .contentSizeCategoryIsAccessibility) { matchesCondition, view in
			view.textAlignment = matchesCondition == true ? accessibility : alignment
		}
	}
}


extension UITextView {
	/// Sets the text alignment for this label in regular content-size mode and in accessibility size mode
	///
	/// Parameters:
	/// 	- alignment: the alignment to use in regular mode
	/// 	- accessibility: the alignment to use in accessibility mode
	///
	/// Return:
	/// 	- `self` is returned, for easy chaining.
	@discardableResult public func textAlignment(_ alignment: NSTextAlignment, accessibility: NSTextAlignment) -> Self {
		return configureDynamically(condition: .contentSizeCategoryIsAccessibility) { matchesCondition, view in
			view.textAlignment = matchesCondition == true ? accessibility : alignment
		}
	}
}
