//
//  UIView+Conditional.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 20/05/2022.
//

import UIKit
import ObjectiveC.runtime

extension UIView {
	/// The callback to create conditional constraints in.
	public typealias ConditionCallback = () -> Void
	
	/// Creates conditional constraints. Constraints created in the `then` or `else` callbacks
	/// will only be applied when the given conditions apply. This allows you to apply different constraints to the same view
	/// and have them automatically be actived/deactivated depending on the given conditions.
	///
	/// In the `then` and `else` callbacks, it is possible to call `addSubview(subview, ...)` multiple times
	/// without the view hierarchy changing: the constraints for those `addSubview()` calls will be conditionally
	/// set.
	///
	/// **Note that you cannot conditionally add a subview to different superviews: that's an error.** This mechanism
	/// only makes the constraints conditional, it doesn't conditionally move views to different super views.
	///
	///  **Also note** that the `then` and `else` blocks are only executed once on creation to capture the created constraints.
	///  If you need custom logic to apply to those constraints, use a `.callback({})-condition`.
	///
	/// - Parameters:
	///  	- condition: the condition when to use constraints created in the `then` block
	///  	- then: a block where all the AutoLayoutConvenience constraints created will only be activated when the given `condition` matches
	///  	- else: **optional** a block where all the AutoLayoutConvenience constraints created will only be actived when the given `condition` does not match
	///
	/// - Returns: returns a `ConditionalResult` that can be used stop updates from coalescing or automatically animate changed.
	@discardableResult public static func `if`(_ condition: Condition, then: ConditionCallback, else: ConditionCallback = {}) -> ConditionalResult {
		return UIView.internalIf(view: nil, condition: condition, then: then, else: `else`)
	}
	
	// alias of `if(_:then:else:)`
	@discardableResult public static func conditionallyConstrain(if condition: Condition, then: ConditionCallback, else: ConditionCallback = {}) -> ConditionalResult {
		return UIView.internalIf(view: nil, condition: condition, then: then, else: `else`)
	}
	
	/// Creates conditional constraints where the condition applies to the given view. Constraints created in the `then` or `else` callbacks
	/// will only be applied when the given conditions apply. This allows you to apply different constraints to the same view
	/// and have them automatically be actived/deactivated depending on the given conditions.
	///
	/// In the `then` and `else` callbacks, it is possible to call `addSubview(subview, ...)` multiple times
	/// without the view hierarchy changing: the constraints for those `addSubview()` calls will be conditionally
	/// set.
	///
	/// **Note that you cannot conditionally add a subview to different superviews: that's an error.** This mechanism
	/// only makes the constraints conditional, it doesn't conditionally move views to different super views.
	///
	///  **Also note** that the `then` and `else` blocks are only executed once on creation to capture the created constraints.
	///  If you need custom logic to apply to those constraints, use a `.callback({})-condition`.
	///
	/// - Parameters:
	/// 	- view: the view that the `condition` should aply to (if the condition is not view-specific)
	///  	- condition: the condition when to use constraints created in the `then` block
	///  	- then: a block where all the AutoLayoutConvenience constraints created will only be activated when the given `condition` matches
	///  	- else: **optional** a block where all the AutoLayoutConvenience constraints created will only be actived when the given `condition` does not match
	///
	/// - Returns: returns a `ConditionalResult` that can be used stop updates from coalescing or automatically animate changed.
	@discardableResult public static func `if`(view: UIView, is condition: Condition, then: ConditionCallback, else: ConditionCallback = {}) -> ConditionalResult {
		return UIView.internalIf(view: view, condition: condition, then: then, else: `else`)
	}
	
	/// alias of `UIView.if(view:is:then:else)` for expressive purposes.
	@discardableResult public static func `if`(view: UIView, has condition: Condition, then: ConditionCallback, else: ConditionCallback = {}) -> ConditionalResult {
		return UIView.internalIf(view: view, condition: condition, then: then, else: `else`)
	}
	
	/// alias of `if(view:is:then:else:)`
	@discardableResult public static func conditionallyConstrain(ifView view: UIView, is condition: Condition, then: ConditionCallback, else: ConditionCallback = {}) -> ConditionalResult {
		return UIView.internalIf(view: nil, condition: condition, then: then, else: `else`)
	}
	
	/// Creates conditional constraints where the condition applies to the given view if that view's
	/// `activeConditionalConstraintsConfigurationName` == `name`t. Constraints created in the configuration
	/// will only be applied when the given name is active. This allows you to apply different constraints to the same view
	/// and have them automatically be actived/deactivated depending on the active configuration.
	///
	/// It is possible to call `addSubview(subview, ...)` multiple times inside of different `addNamedConditionalConfiguration`
	/// configuration callbacks without the view hierarchy changing: the constraints for those `addSubview()` calls will be conditionally
	/// set.
	///
	/// **Note that you cannot conditionally add a subview to different superviews: that's an error.** This mechanism
	/// only makes the constraints conditional, it doesn't conditionally move views to different super views.
	///
	///  **Also note** that the configuration block is only executed once, not dynamically.
	///  If you need custom logic to apply to those constraints, use a `.callback({})-condition`.
	///
	/// - Parameters:
	///  	- name: the name for this configuration.
	///  	- configuration: a block where all the AutoLayoutConvenience constraints created will only be activated when the given conditional configuration name is active for the view.
	@discardableResult public static func addNamedConditionalConfiguration(_ name: UIView.Condition.ConfigurationName, configuration: ConditionCallback) -> ConditionalResult {
		return UIView.internalIf(view: nil, condition: .name(is: name), then: configuration, else: {})
	}
	
	/// Helper for `addNamedConditionalConfiguration(name:configuration)` that sets multiple configurations at once.
	@discardableResult public static func addNamedConditionalConfigurations(configurations: [UIView.Condition.ConfigurationName: ConditionCallback]) -> ConditionalResult {
		UIView.internalIf(view: nil, condition: .alwaysTrue, then: {
			configurations.forEach { UIView.addNamedConditionalConfiguration($0.key, configuration: $0.value) }
		}, else: {})
	}
	
	/// Any conditional  constraint updates for this view should be directly applied instead of being coalesced.
	/// See the discussion in `#ConditionalResult.withoutCoalescing()`
	@discardableResult public func useDirectConditionalUpdates() -> Self {
		ensureConstraintsListCollection().stopCoalescingUpdates()
		return self
	}
	
	/// Any conditional constraint updates for this view should be animated.
	/// See the discussion in `ConditionalResult.animateChanges()`
	@discardableResult public func enableAnimationsForConditionalUpdates() -> Self {
		ensureConstraintsListCollection().animateUpdates()
		return self
	}
	
	/// Update any pending conditional constraints for this view.
	public func updateConditionalConstraintsIfNeeded() {
		constraintsListCollection?.updateIfNeeded()
	}
	
	/// Mark our conditional constraints as needing an update.
	public func setConditionalConstraintsNeedsUpdate() {
		constraintsListCollection?.setNeedsUpdate()
	}
	
	/// Force a conditional constraint update for this view.
	public func forceUpdateConditionalConstraints() {
		constraintsListCollection?.update()
	}
	
	/// If using named conditions, this is the name of active configuration. Defaults to `main`
	public var activeConditionalConstraintsConfigurationName: UIView.Condition.ConfigurationName {
		get { constraintsListCollection?.activeConfigurationName ?? .main }
		set { ensureConstraintsListCollection().activeConfigurationName = newValue }
	}

	/// The result of a conditional function. Can be used to apply properties to all of the created constraints.
	public struct ConditionalResult {
		fileprivate var collections = [ConstraintsListCollection]()
		
		/// When there are multiple conditions, all conditional constraint updates will be coalesced
		/// to be applied at the end of the runloop. Sometimes this is not desirable and we want to update
		/// our conditional contraints directly, without coalescing. Call this method on an conditional
		/// constraint statement to stop coalescing on all created conditional constraints.
		@discardableResult public func withoutCoalescing() -> Self {
			collections.forEach { $0.stopCoalescingUpdates() }
			return self
		}
		
		/// By default, conditional constraints are applied as if. Call this to automatically always
		/// // animate change in the created conditional constraints.
		@discardableResult public func animateChanges() -> Self {
			collections.forEach { $0.animateUpdates() }
			return self
		}
	}
	
	/// All constraints created in the given block are only activated after running the block: this allows creating
	/// inter-view constraints using addSubview() without running into exceptions when the views are not
	/// yet in the same hierarchy.
	///
	/// Note: it is safe to nest calls to this function: only at the end outer call will constraints be activated.
	///
	/// - Example:
	/// E.g.
	/// 	addSubview(someView, filling: .relative(someOtherView))
	///		addSubview(someOtherView, centeredIn: .superview)
	///
	/// - Parameters:
	///  	- running: a block where all the AutoLayoutConvenience constraints created will only be activated after the block ran
	public static func batchConstraints(_ running: () -> Void) {
		ConstraintsList.delayActivation(running)
	}
}

extension UIView {
	/// gets the constraints list for this view
	fileprivate static var collectionListKey = 0
	fileprivate var constraintsListCollection: ConstraintsListCollection? {
		objc_getAssociatedObject(self, &Self.collectionListKey) as? ConstraintsListCollection
	}
	
	/// Private method that ensures a constraint lisr collection for this view exists
	fileprivate func ensureConstraintsListCollection() -> ConstraintsListCollection {
		if let collection = constraintsListCollection {
			return collection
		} else {
			let collection = ConstraintsListCollection(view: self)
			objc_setAssociatedObject(self, &Self.collectionListKey, collection, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return collection
		}
	}
	
	/// Used so we can stack  recursively nest multiple `internalIf()` calls and have the right constraints be build.
	/// E.g. `UIView.if(.verticallyCompact) { UIView.if(.phone) {  addSubview(...) } }` needs to result in the addSubview()-constraints
	/// requring both `.verticallyCompact` and `.phone`. We do this by keeping track of the  "active conditions."
	fileprivate static var activeConditions = [Condition]()
	
	/// This is used so we only install collections when we have no deeper nesting.
	fileprivate static var currentIfNestingDepth = 0
	fileprivate static var allTouchedConstraintsLists = [UIView: ConstraintsListCollection]()
	
	fileprivate static func internalIf(view: UIView?, condition: Condition, then: ConditionCallback, else: ConditionCallback) -> ConditionalResult {
		Self.currentIfNestingDepth += 1
		var collections = [UIView: ConstraintsListCollection]()
		
		// local function to intercept the constraints created in a block with a given condition.
		func intercept(condition: Condition, running: ConditionCallback) {
			// bind the condition to the view that is passed in, if possible.
			Self.activeConditions.append(condition.bind(to: view))
			
			ConstraintsList.intercept({ list, view in
				guard let view else { return }
				let collection = view.ensureConstraintsListCollection()
				collections[view] = collection
				collection.add(list, conditions: Self.activeConditions)
			}, while: running)

			Self.activeConditions.removeLast()
		}
		
		// execute both blocks for the given condition. Else is just the negated if condition.
		UIView.ignoreSpuriousAddSubviewForAutoLayoutCalls {
			intercept(condition: condition, running: then)
			intercept(condition: condition.isFalse, running: `else`)
		}
		
		// add the newly created conditions to the list of all touched conditions
		collections.forEach { Self.allTouchedConstraintsLists[$0.key] = $0.value }
		Self.currentIfNestingDepth -= 1
		if Self.currentIfNestingDepth == 0 {
			// if we're at the outer nested if() block, install all touched conditions
			// and reset the touch list.
			for collection in Self.allTouchedConstraintsLists.values {
				collection.install()
			}
			Self.allTouchedConstraintsLists.removeAll()
		}
		
		// return a list of collections so the caller can apply methods to it.
		return ConditionalResult(collections: Array(collections.values))
	}
}
