//
//  Cancellable.swift
//  AutoLayoutConvenienceDemo
//
//  Created by Andreas Verhoeven on 26/04/2023.
//

import Foundation

/// Object that models something that can be cancelled. Upon calling cancel() the callback will be called.
/// If `cancelOnDeInit` is true, the `cancel()` method will automatically be called on deinit of this object,
/// effectively making this object keeping the operation it is tied to alive.
public final class Cancellable: NSObject {
	private(set) public var callback: (() -> Void)?
	private(set) public var cancelsOnDeInit: Bool
	
	/// Creates a Cancellable.
	public init(cancelsOnDeInit: Bool = true, callback: @escaping () -> Void) {
		self.cancelsOnDeInit = cancelsOnDeInit
		self.callback = callback
		super.init()
	}
	
	
	/// Removes notificationCenterObserver from `NotificationCenter.default` upon cancel
	convenience public init(notificationCenterObserver: NSObjectProtocol) {
		self.init(cancelsOnDeInit: false, callback: {
			NotificationCenter.default.removeObserver(notificationCenterObserver)
		})
	}
	
	/// Will automatically call `cancel()` if this object is de-inited.
	public var automaticallyCancellingOnDeInit: Self {
		self.cancelsOnDeInit = true
		return self
	}
	
	deinit {
		guard cancelsOnDeInit == true else { return }
		cancel()
	}
	
	/// Cancels the object once.
	public func cancel() {
		guard let callback = callback else { return }
		self.callback = nil
		callback()
	}
}
