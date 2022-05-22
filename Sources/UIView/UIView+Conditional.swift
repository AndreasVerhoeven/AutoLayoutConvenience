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
		UIView.internalIf(view: nil, condition: condition, then: then, else: `else`)
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
		UIView.internalIf(view: view, condition: condition, then: then, else: `else`)
	}
	
	/// alias of `UIView.if(view:is:then:else)` for expressive purposes.
	@discardableResult public static func `if`(view: UIView, has condition: Condition, then: ConditionCallback, else: ConditionCallback = {}) -> ConditionalResult {
		UIView.internalIf(view: view, condition: condition, then: then, else: `else`)
	}
	
	
	/// Any conditional  constraint updates for this view should be directly applied instead of being coalesced.
	/// See the discussion in `#ConditionalResult.withoutCoalescing()`
	@discardableResult public func useDirectConditionalUpdates() -> Self {
		ensureConstraintsListCollection().stopCoalescingUpdates()
		return self
	}
	
	/// Any conditional constraint updates for this view should be animated.
	/// See the discussion in `ConditionalResult.animateChanges()`
	@discardableResult public func animateConditionalChanges() -> Self {
		ensureConstraintsListCollection().animateUpdates()
		return self
	}
	
	/// Update any pending conditional constraints for this view.
	public func updateConditionalConstraintsIfNeeded() {
		constraintsListCollection?.updateIfNeeded()
	}
	
	/// Force a conditional constraint update for this view.
	public func forceUpdateConditionalConstraints() {
		constraintsListCollection?.update()
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
}

extension UIView {
	fileprivate static var collectionListKey = 0
	fileprivate var constraintsListCollection: ConstraintsListCollection? {
		objc_getAssociatedObject(self, &Self.collectionListKey) as? ConstraintsListCollection
	}
	fileprivate func ensureConstraintsListCollection() -> ConstraintsListCollection {
		if let collection = constraintsListCollection {
			return collection
		} else {
			let collection = ConstraintsListCollection(view: self)
			objc_setAssociatedObject(self, &Self.collectionListKey, collection, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
			return collection
		}
	}
	
	fileprivate static var conditionStack = [Condition]()
	fileprivate static var conditionsDepth = 0
	fileprivate static var allTouchedConstraintsLists = [UIView: ConstraintsListCollection]()
	
	fileprivate static func internalIf(view: UIView?, condition: Condition, then: ConditionCallback, else: ConditionCallback) -> ConditionalResult {
		Self.conditionsDepth += 1
		var collections = [UIView: ConstraintsListCollection]()
		
		func intercept(condition: Condition, running: ConditionCallback) {
			Self.conditionStack.append(condition.rebound(to: view))
			
			ConstraintsList.intercept({ list, view in
				let collection = view.ensureConstraintsListCollection()
				collections[view] = collection
				collection.add(list, conditions: Self.conditionStack)
			}, while: running)

			Self.conditionStack.removeLast()
		}
		
		UIView.ignoreSpuriousAddSubviewForAutoLayoutCalls {
			intercept(condition: condition, running: then)
			intercept(condition: condition.isFalse, running: `else`)
		}
		
		collections.forEach { Self.allTouchedConstraintsLists[$0.key] = $0.value }
		Self.conditionsDepth -= 1
		if Self.conditionsDepth == 0 {
			for collection in Self.allTouchedConstraintsLists.values {
				collection.start()
			}
			Self.allTouchedConstraintsLists.removeAll()
		}
		
		return ConditionalResult(collections: Array(collections.values))
	}
}
