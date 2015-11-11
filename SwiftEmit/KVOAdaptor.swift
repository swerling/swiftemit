//
//  KVOAdaptor.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation

extension Event {
  typealias KVO = SwiftEmit.Event.ValueChange
}

class SwiftEmitAdaptorForNSKVO: NSObject, NS {
  
  let NullValue  = "__KVO_CHANGED_VALUE_WAS_NULL__"
  
  var context: UnsafeMutablePointer<Void>
  var handler: Handler
  var keyPath: String
  var observee: NSObject
  var observing = false
  
  let options =  NSKeyValueObservingOptions([.New, .Old])
  
  static func observe(observee observee: NSObject, keyPath: String,
    handler: Handler) -> SwiftEmitAdaptorForNSKVO {
    var ctx = Float()
    return SwiftEmitAdaptorForNSKVO(
      observee: observee, keyPath: keyPath, context: &ctx, handler: handler)
  }
  
  static func observeFloat(observee observee: NSObject, keyPath: String,
    handler: Handler) -> SwiftEmitAdaptorForNSKVO {
    var ctx = Float()
    return SwiftEmitAdaptorForNSKVO(
      observee: observee, keyPath: keyPath, context: &ctx, handler: handler)
  }
  
  init(observee: NSObject,
    keyPath: String,
    context: UnsafeMutablePointer<Void>,
    handler: Handler) {
    self.observee = observee
    self.keyPath = keyPath
    self.context = context
    self.handler = handler
  }
  
  deinit {
    stopObserving()
  }
  
  func startObserving() -> Bool {
    guard !observing else { return false }
   
    observee.addObserver(self,
      forKeyPath: keyPath,
      options: options,
      context: context)
    
    observing = true
    
    return true
  }
  
  func stopObserving() -> Bool {
    guard observing else { return false }
    
    observee.removeObserver(self, forKeyPath: keyPath)
    observing = false
    
    return true
  }
  
  override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    
    //print("=== Observe: \(keyPath)")
    
    guard keyPath == self.keyPath  && context == self.context else {
      return super.observeValueForKeyPath(nil,
        ofObject: object,
        change: change,
        context: context)
    }
    
    var oldVal: AnyObject?
    var newVal: AnyObject?
    if let c = change {
      if let ov = c[NSKeyValueChangeOldKey] { oldVal = ov }
      if let nv = c[NSKeyValueChangeNewKey] { newVal = nv }
    }
    
    handler(Event.KVO(oldValue: oldVal, newValue: newVal))
  }
  
}