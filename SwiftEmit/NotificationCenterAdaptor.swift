//
//  NotificationCenterAdaptor.swift
//  SwiftEmit
//
//
//  Eg. in application init:
//
//     var nsObservers = [PubSubNS]()
//
//     nsObservers.append(EventAdaptorForNSKVO.observeFloat(
//       observee: backCameraDevice, keyPath: "adjustingFocus") {
//         event in
//         self.handleAdjustingFocus()
//       })
//
//  In applicationDidBecomeActive

//      for observer in nsObservers { observer.startObserving() }
//
//  In applicationWillResignActive

//      for observer in nsObservers { observer.stopObserving() }

//  Created by Steven Swerling on 10/2/15.
//  Copyright © 2015 spswerling. All rights reserved.
//

/*
import Foundation

typealias NotificationCenterEvent = BasicEvent

extension NSNotificationCenter {
  public func swiftEmit(eventName:String, handler: Handler)
    -> AdaptorForNSNotificationCenter
  {
    return AdaptorForNSNotificationCenter(
      noticationCenterEventName: eventName,
      handler: handler)
  }
}

public class AdaptorForNSNotificationCenter: SwiftEmitNS {
  
  var observing = false
  var handler: Handler
  var notificationCenterEventName: String
  
  init(noticationCenterEventName name: String, handler: Handler) {
    self.notificationCenterEventName = name
    self.handler = handler
  }
  
  deinit {
    stopObserving()
  }
  
  public override func startObserving() -> Bool {
    guard !observing else { return false }
   
    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "handle",
      name: notificationCenterEventName,
      object: nil)
    
    observing = true
    
    return true
  }
  
  public override func stopObserving() -> Bool {
    guard observing else { return false }
   
    NSNotificationCenter.defaultCenter().removeObserver(self)
    observing = false
    
    return true
  }
  
  func handle() {
    handler(NotificationCenterEvent())
  }
  
}
*/