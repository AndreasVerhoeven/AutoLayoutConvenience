//
//  AutoAdjustingStackView.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 14/08/2025.
//

import UIKit

/// A UIStackView that configurates itself dynamically using the `configurationUpdateHandler`
/// when the environment changes (e.g traits).
public class AutoAdjustingStackView: UIStackView {
	/// The `ConfigurationUpdateHandler` struct  that holds the callback that will be called to configure
	/// the stackview on environmental changes. Implements `callAsFunction()`
	public struct ConfigurationUpdateHandler {
		public typealias Callback = (AutoAdjustingStackView) -> Void
		public var callback: Callback
		fileprivate var conditionToInstall: UIView.Condition?

		/// Creates a handler with a given callback closure
		public init(_ callback: @escaping Callback) {
			self.callback = callback
		}

		fileprivate init(_ condition: UIView.Condition, callback: @escaping Callback) {
			self.conditionToInstall = condition
			self.callback = callback
		}

		/// This struct can be called as a function, so it looks like a closure.
		public func callAsFunction(_ stackView: AutoAdjustingStackView) {
			callback(stackView)
		}

		/// Returns a new handler that first calls the current handler's callback and then calls the extra callback passed in.
		public func chained(with callback: @escaping Callback) -> Self {
			let existingCallback = self.callback
			return Self { stackView in
				existingCallback(stackView)
				callback(stackView)
			}
		}

		/// Returns a new handler that first calls the current handler's callback and then calls the passed in handler's callback
		public func chained(with handler: Self) -> Self {
			return chained(with: handler.callback)
		}

		/// Creates a handler with a given callback closure
		static func custom(_ callback: @escaping Callback) -> Self {
			return Self(callback)
		}

		/// Configures the stackview to be horizontally in regular mode with the given alignment, distribution and spacing,
		/// but vertically in accessibility mode, with __optional__ overrides for the alignment, distribution and spacing
		static func horizontallyRegularVerticallyAccessibility(
			alignment: Alignment = .fill,
			distribution: Distribution = .fill,
			spacing: CGFloat = 0,
			accessibilityAlignment: Alignment? = nil,
			accessibilityDistribution: Distribution? = nil,
			accessibilitySpacing: CGFloat? = nil,
		) -> Self {
			return regularWithAlternative(
				axis: .horizontal,
				alignment: alignment,
				distribution: distribution,
				spacing: spacing,
				alternativeAxis: .vertical,
				alternativeAlignment: accessibilityAlignment,
				alternativeDistribution: accessibilityDistribution,
				alternativeSpacing: accessibilitySpacing,
				isAlternative: { $0.traitCollection.preferredContentSizeCategory.isAccessibilityCategory }
			)
		}

		/// Configures the stackview to be in one of two modes: regular, or alternative, depending on the result of the `isAlternative`
		/// callback.
		static func regularWithAlternative(
			axis: NSLayoutConstraint.Axis,
			alignment: Alignment = .fill,
			distribution: Distribution = .fill,
			spacing: CGFloat = 0,
			alternativeAxis: NSLayoutConstraint.Axis? = nil,
			alternativeAlignment: Alignment? = nil,
			alternativeDistribution: Distribution? = nil,
			alternativeSpacing: CGFloat? = nil,
			isAlternative: @escaping (AutoAdjustingStackView) -> Bool
		) -> Self {
			return .custom({ stackView in
				if isAlternative(stackView) == false {
					stackView.axis = axis
					stackView.alignment = alignment
					stackView.distribution = distribution
					stackView.spacing = spacing
				} else {
					stackView.axis = (alternativeAxis ?? axis)
					stackView.alignment = (alternativeAlignment ?? alignment)
					stackView.distribution = (alternativeDistribution ?? distribution)
					stackView.spacing = (alternativeSpacing ?? spacing)
				}
			})
		}

		/// Configures the stackview to be in one of two modes: regular, or alternative, depending on the result of the `isAlternative`
		/// condition.
		static func regularWithAlternative(
			axis: NSLayoutConstraint.Axis,
			alignment: Alignment = .fill,
			distribution: Distribution = .fill,
			spacing: CGFloat = 0,
			alternativeAxis: NSLayoutConstraint.Axis? = nil,
			alternativeAlignment: Alignment? = nil,
			alternativeDistribution: Distribution? = nil,
			alternativeSpacing: CGFloat? = nil,
			isAlternative condition: UIView.Condition
		) -> Self {
			let handler = regularWithAlternative(
				axis: axis,
				alignment: alignment,
				distribution: distribution,
				spacing: spacing,
				alternativeAxis: alternativeAxis,
				alternativeAlignment: alternativeAlignment,
				alternativeDistribution: alternativeDistribution,
				alternativeSpacing: alternativeSpacing,
				isAlternative: { stackView in stackView.conditionList?.conditionIsActive == true }
			)

			return Self(condition) { stackView in
				handler(stackView)
			}
		}
	}
	
	/// This will be called when the trait collection changes, on set up and other events.
	/// You get passed in the `AutoAdjustingStackView` you can modify so that it
	/// matches the environment
	public var configurationUpdateHandler: ConfigurationUpdateHandler? {
		didSet {
			conditionList = nil

			if let condition = configurationUpdateHandler?.conditionToInstall {
				conditionList = SingleConditionList(condition: condition, stackView: self)
				conditionList?.install()
			}
		}
	}

	/// Creates an `AutoAdjustingStackView` with the given views, insets and handler
	public convenience init(
		with views: [UIView] = [],
		insets: NSDirectionalEdgeInsets? = nil,
		handler: ConfigurationUpdateHandler
	) {
		self.init()
		_ = { configurationUpdateHandler = handler }()
		addArrangedSubviews(views)
		updateConfiguration()
	}

	/// Creates an `AutoAdjustingStackView` with the given views, insets and handler
	public convenience init(
		with views: UIView...,
		insets: NSDirectionalEdgeInsets? = nil,
		handler: ConfigurationUpdateHandler
	) {
		self.init(with: views, insets: insets, handler: handler)
	}

	internal var conditionHandler: UIView.Condition.ConditionHandler? {
		return conditionList
	}

	// MARK: - Privates

	private var conditionList: SingleConditionList?

	private func updateConfiguration() {
		configurationUpdateHandler?(self)
	}

	private func copyConstraintListConfigurationToConditionList() {
		//configurationUpdateCallback
	}

	// MARK: - UIView
	
	override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
		super.traitCollectionDidChange(traitCollection)
		updateConfiguration()
	}

	override public init(frame: CGRect) {
		super.init(frame: frame)
		updateConfiguration()
	}

	required public init(coder: NSCoder) {
		super.init(coder: coder)
		updateConfiguration()
	}
}

fileprivate extension AutoAdjustingStackView {
	class SingleConditionList: ConditionList<SingleConditionList.Item> {
		struct Item: UIView.Condition.ItemProvider {
			var id = UUID()
			var condition: UIView.Condition
		}

		init(condition: UIView.Condition, stackView: AutoAdjustingStackView) {
			super.init(view: stackView)
			items.append(Item(condition: condition))
		}

		fileprivate var conditionIsActive = false

		override func applyUpdates(_ activeItems: [Item], inactiveItems: [Item], view: UIView, animated: Bool) {
			conditionIsActive = (activeItems.isEmpty == false)

			if let stackView = view as? AutoAdjustingStackView {
				stackView.updateConfiguration()
			}
		}
	}
}
