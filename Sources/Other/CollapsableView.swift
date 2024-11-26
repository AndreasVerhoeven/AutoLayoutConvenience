//
//  CollapsableView.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 21/11/2024.
//

import UIKit

/// This view can be collapsed to 0 height/width, while its
/// contents isn't resized, but clipped.
/// This can be useful if you have a list of views and want to collapse
/// something for a short while, while not deforming/resizing the other view.
///
/// You can add anything to the `contentView`, as long as you make sure
/// that it has a defined height/width depending on the edge you set:
/// either by setting an explicit height constraint on it or adding a
/// subview that has an intrinsic or defined height.
open class CollapsableView: UIView {
	/// the content view we show. Add your own subviews here.
	public let contentView = UIView()

	/// Convenience init for adding a view to the content view directly.
	public convenience init(view: UIView, edge: Edge = .top) {
		self.init(frame: .zero)
		contentView.addSubview(view, filling: .superview)
		updatePinnedToEdge()
	}

	/// Convenience init for initializing some properties directly
	public convenience init(animationOptions: AnimationOptions, edge: Edge = .top) {
		self.init(frame: .zero)
		self.animationOptions = animationOptions
		self.edge = edge
		updatePinnedToEdge()
	}

	/// Convenience init for adding a view to the content view directly.
	public convenience init(edge: Edge) {
		self.init(frame: .zero)
		self.edge = edge
		updatePinnedToEdge()
	}

	/// If true, this view is expanded to its actual height. If false, it will have a height of 0.
	open var isExpanded: Bool {
		get { _isExpanded }
		set { setIsExpanded(newValue, animated: false) }
	}

	/// expands or collapses the view. If animated is true, will be animated with
	/// the animationOptions set.
	open func setIsExpanded(_ isExpanded: Bool, animated: Bool) {
		guard self.isExpanded != isExpanded else { return }

		_isExpanded = isExpanded

		if animated == true {
			UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction, .allowAnimatedContent], animations: {
				self.update()

				if self.animationOptions.contains(.dontRelayout) == false {
					self.forceLayoutInViewHierarchy()
				}
			})
		} else {
			update()
		}
	}

	/// defines which edge we are pinned to
	public enum Edge {
		case top
		case bottom
		case leading
		case trailing

		fileprivate var isVertical: Bool {
			switch self {
				case .top: return true
				case .bottom: return true
				case .leading: return false
				case .trailing: return false
			}
		}

		fileprivate var edgeConditionalName: UIView.Condition.ConfigurationName {
			switch self {
				case .top: return .top
				case .bottom: return .bottom
				case .leading: return .leading
				case .trailing: return .trailing
			}
		}
	}

	/// The edge we try to stick too
	var edge = Edge.top {
		didSet {
			guard edge != oldValue else { return }
			updatePinnedToEdge()
		}
	}

	/// Defines the options we have for animation
	public struct AnimationOptions: RawRepresentable, OptionSet {
		public var rawValue: Int

		public init(rawValue: Int) {
			self.rawValue = rawValue
		}

		/// The content fades out when collapsed
		public static let fade = Self(rawValue: 1 << 0)

		/// The content scales when collapsed
		public static let scale = Self(rawValue: 1 << 1)

		/// The layout is animated automatically when collapsed/expanded. Set this
		/// option if you want to control the layout animations yourselves, e.g. if you are in
		/// a stack view that is animated already.
		public static let dontRelayout = Self(rawValue: 1 << 2)

		/// The default animation options
		public static let `default`: Self = [.fade]
	}

	/// the options to use when animating from/to expanded state.
	open var animationOptions = AnimationOptions.default {
		didSet {
			guard animationOptions != oldValue else { return }
			update()
		}
	}

	/// sets animation options on this view directly, while returning self, so it can be chained in initializer calls.
	public func withAnimationOptions(_ options: AnimationOptions) -> Self {
		self.animationOptions = options
		return self
	}

	// MARK: - Privates
	private var _isExpanded = true

	private let containerView = UIView()
	private let innerContainerView = UIView()

	private func update() {
		innerContainerView.alpha = (animationOptions.contains(.fade) == true && isExpanded == false ? 0 : 1)
		innerContainerView.transform = (animationOptions.contains(.scale) == true && isExpanded == false ? CGAffineTransform(scaleX: 0.9, y: 0.9) : .identity)

		UIView.performWithoutAnimation {
			updateExpandedState()
		}
	}

	private func updateExpandedState() {
		containerView.activeConditionalConstraintsConfigurationName = stateConditionalName(isExpanded: isExpanded, isVertical: edge.isVertical)
	}

	private func updatePinnedToEdge() {
		UIView.performWithoutAnimation {
			innerContainerView.activeConditionalConstraintsConfigurationName = edge.edgeConditionalName
		}
	}

	private func stateConditionalName(isExpanded: Bool, isVertical: Bool) -> UIView.Condition.ConfigurationName {
		switch (isExpanded, edge.isVertical) {
			case (true, true): return .combined(.expanded, .vertical)
			case (true, false): return .combined(.expanded, .horizontal)
			case (false, true): return .combined(.collapsed, .vertical)
			case (false, false): return .combined(.collapsed, .vertical)
		}
	}

	// MARK: - UIView
	open override func layoutSubviews() {
		super.layoutSubviews()

		switch edge {
			case .top:
				/// pin those at 0 during animations
				self.contentView.frame.origin.y = 0
				self.containerView.frame.origin.y = 0
				self.innerContainerView.frame.origin.y = 0

			case .bottom:
				break

			case .leading:
				break

			case .trailing:
				break
		}
	}

	public override init(frame: CGRect) {
		super.init(frame: frame)

		innerContainerView.addSubview(contentView, filling: .superview)
		addSubview(containerView, filling: .superview)

		containerView.clipsToBounds = true

		// set up edge constraints
		UIView.addNamedConditionalConfiguration(Edge.top.edgeConditionalName) {
			containerView.addSubview(innerContainerView, pinnedTo: .top)
		}

		UIView.addNamedConditionalConfiguration(Edge.bottom.edgeConditionalName) {
			containerView.addSubview(innerContainerView, pinnedTo: .bottom)
		}

		UIView.addNamedConditionalConfiguration(Edge.leading.edgeConditionalName) {
			containerView.addSubview(innerContainerView, pinnedTo: .leading)
		}

		UIView.addNamedConditionalConfiguration(Edge.trailing.edgeConditionalName) {
			containerView.addSubview(innerContainerView, pinnedTo: .trailing)
		}

		// set up collapsed state constraints
		UIView.addNamedConditionalConfiguration(stateConditionalName(isExpanded: false, isVertical: false)) {
			containerView.constrain(width: 0)
		}

		UIView.addNamedConditionalConfiguration(stateConditionalName(isExpanded: true, isVertical: false)) {
			containerView.constrain(width: .exactly(sameAs: innerContainerView))
		}

		UIView.addNamedConditionalConfiguration(stateConditionalName(isExpanded: false, isVertical: true)) {
			containerView.constrain(height: 0)
		}

		UIView.addNamedConditionalConfiguration(stateConditionalName(isExpanded: true, isVertical: true)) {
			containerView.constrain(height: .exactly(sameAs: innerContainerView))
		}

		updatePinnedToEdge()
		updateExpandedState()
	}

	@available(*, unavailable)
	public required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
}
