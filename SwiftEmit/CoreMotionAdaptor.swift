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
    public let error: NSError?
    public init(motion: CMDeviceMotion?, error: NSError?) {
      self.motion = motion
      self.error = error
    }
  }
}

public class AdaptorForCoreMotion: SwiftEmitNS {
  
  let motionManager: CMMotionManager!
  let nsOpQueue: NSOperationQueue?
  let updateInterval: NSTimeInterval
  private var observing = false
  
  init(motionManager: CMMotionManager = CMMotionManager(),
    queue: NSOperationQueue? = NSOperationQueue.currentQueue(),
    updateInterval: NSTimeInterval = 1.0)
  {
    self.motionManager = motionManager
    self.nsOpQueue = queue
    self.updateInterval = updateInterval
  }
  
  deinit {
    stopObserving()
  }
  
  public override func startObserving() -> Bool {
    guard !observing else { return false }
   
    observing = true
    
    motionManager.deviceMotionUpdateInterval = updateInterval
    
    guard let queue = nsOpQueue else {
      print("WARNING: Could not start core motion observer, no op Q found")
      return false
    }
    
    motionManager.startDeviceMotionUpdatesToQueue(queue) {
      (deviceMotion, error) in
      self.handleDeviceMotionUpdate(deviceMotion, error)
    }
    
    return true
  }
  
  public override func stopObserving() -> Bool {
    guard observing else { return false }
   
    motionManager.stopDeviceMotionUpdates()
    observing = false
    
    return true
  }
  
  private func handleDeviceMotionUpdate(motion: CMDeviceMotion?, _ error: NSError?) {
    emit(Events.DeviceMotionEvent(motion: motion, error: error))
  }
  
}

extension CMMotionManager {
  public func swiftEmit(
    queue: NSOperationQueue? = NSOperationQueue.currentQueue(),
    updateInterval: NSTimeInterval = 1.0,
    handler: Handler)
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
  