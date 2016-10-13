//
//  CoreMotionAdaptor.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation

//
//  PubSubCoreMotion.swift
//  Frank
//
//  Created by Steven Swerling on 10/2/15.
//  Copyright © 2015 spswerling. All rights reserved.
//

import Foundation
import CoreMotion

extension Events {
  public struct DeviceMotionEvent {
    public let motion: CMDeviceMotion?
    public let error: Error?
    public init(motion: CMDeviceMotion?, error: Error?) {
      self.motion = motion
      self.error = error
    }
  }
}

open class AdaptorForCoreMotion: SwiftEmitNS {
  
  let motionManager: CMMotionManager!
  let nsOpQueue: OperationQueue?
  let updateInterval: TimeInterval
  fileprivate var observing = false
  
  init(motionManager: CMMotionManager = CMMotionManager(),
    queue: OperationQueue? = OperationQueue.current,
    updateInterval: TimeInterval = 1.0)
  {
    self.motionManager = motionManager
    self.nsOpQueue = queue
    self.updateInterval = updateInterval
  }
  
  deinit {
    stopObserving()
  }
  
  @discardableResult open override func startObserving() -> Bool {
    guard !observing else { return false }
   
    observing = true
    
    motionManager.deviceMotionUpdateInterval = updateInterval
    
    guard let queue = nsOpQueue else {
      print("WARNING: Could not start core motion observer, no op Q found")
      return false
    }
    
    motionManager.startDeviceMotionUpdates(to: queue) {
      (deviceMotion, error) in
      self.handleDeviceMotionUpdate(motion: deviceMotion, error: error)
    }
    
    return true
  }
  
  @discardableResult open override func stopObserving() -> Bool {
    guard observing else { return false }
   
    motionManager.stopDeviceMotionUpdates()
    observing = false
    
    return true
  }
  
  fileprivate func handleDeviceMotionUpdate(motion: CMDeviceMotion?, error: Error?) {
    emit(Events.DeviceMotionEvent(motion: motion, error: error))
  }
  
}

extension CMMotionManager {
  @discardableResult public func swiftEmit(
    queue: OperationQueue? = OperationQueue.current,
    updateInterval: TimeInterval = 1.0,
    handler: @escaping Handler)
    -> AdaptorForCoreMotion
  {
    let adaptor = AdaptorForCoreMotion(
      motionManager: self,
      queue: queue,
      updateInterval: updateInterval)
    adaptor.on(Events.DeviceMotionEvent.self, run: handler)
    return adaptor
  }
}
  
