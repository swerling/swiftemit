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

import Foundation

extension Events {
  public struct NotificationCenterEvent{}
}

extension NotificationCenter {
  @discardableResult public func swiftEmit(_ eventName:String, handler: @escaping Handler)
    -> AdaptorForNSNotificationCenter
  {
    let adaptor = AdaptorForNSNotificationCenter(
      noticationCenterEventName: eventName)
    adaptor.on(Events.NotificationCenterEvent.self, run: handler)
    return adaptor
  }
}

open class AdaptorForNSNotificationCenter: SwiftEmitNS {
  
  var observing = false
  var notificationCenterEventName: String
  
  init(noticationCenterEventName name: String) {
    self.notificationCenterEventName = name
  }
  
  deinit {
    stopObserving()
  }
  
  open override func startObserving() -> Bool {
    guard !observing else { return false }
   
    NotificationCenter.default.addObserver(self,
      selector: #selector(AdaptorForNSNotificationCenter.handle),
      name: NSNotification.Name(rawValue: notificationCenterEventName),
      object: nil)
    
    observing = true
    
    return true
  }
  
  @discardableResult open override func stopObserving() -> Bool {
    guard observing else { return false }
   
    NotificationCenter.default.removeObserver(self)
    observing = false
    
    return true
  }
  
  func handle() {
    emit(Events.NotificationCenterEvent())
  }
  
}
