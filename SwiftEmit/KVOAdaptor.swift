//
//  KVOAdaptor.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation

extension NSObject {
  
  public func swiftEmitFloat(keyPath:String, handler: Handler)
    -> AdaptorForNSKVO?
  {
    var context = Float()
    return swiftEmit(onKeyPath: keyPath, context: &context, handler: handler)
  }
  
  // see #swiftEmitFloat for example context creation.
  public func swiftEmit(onKeyPath kp:String,
    context: UnsafeMutablePointer<Void>,
    handler: Handler) -> AdaptorForNSKVO
  {
    return AdaptorForNSKVO(
      observee: self,
      keyPath: kp,
      context: context,
      handler: handler)
  }
}

public class KVOEvent: ValueChangeEvent {}

public class AdaptorForNSKVO: SwiftEmitNS {
  
  let NullValue  = "__KVO_CHANGED_VALUE_WAS_NULL__"
  
  var context: UnsafeMutablePointer<Void>
  var handler: Handler
  var keyPath: String
  var observee: NSObject
  var observing = false
  
  let options =  NSKeyValueObservingOptions([.New, .Old])
  
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
  
  public override func startObserving() -> Bool {
    guard !observing else { return false }
   
    observee.addObserver(self,
      forKeyPath: keyPath,
      options: options,
      context: context)
    
    observing = true
    
    return true
  }
  
  public override func stopObserving() -> Bool {
    guard observing else { return false }
    
    observee.removeObserver(self, forKeyPath: keyPath)
    observing = false
    
    return true
  }
  
  override public func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
    
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
    
    handler(KVOEvent(oldValue: oldVal, newValue: newVal))
  }
  
}