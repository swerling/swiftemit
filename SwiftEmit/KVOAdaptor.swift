//
//  KVOAdaptor.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation

extension NSObject {
  
  // Help, cannot figure out how to make an entry point into this that 
  // looks like this:
  //    swiftEmit(UInt8(), keyPath: 'somepath') { event in.... }
  // I gave up for now and created the helper methods below instead
  /*
  public func swiftEmitX(inout ctx: UnsafeMutablePointer<Void>, keyPath:String, handler: Handler) -> AdaptorForNSKVO?  {
    return swiftEmit(onKeyPath: keyPath, context: &ctx1, handler: handler)
  }*/
  

  /**
   KVO for Int8, Int16, Int32, etc
   
   Example:
   
        device.swiftEmitInt(Int8(), keyPath: "myInt8Var") { event in
          let x = (event as? Events.KVO)?.newValue as? Int
          print("The value is \(x)")
        }
   
   - Parameter T: An instance of the signed integer type, eg. Int8(), Int16()
   - Parameter keyPath: the KVO keypath
   - Parameter handler: a SwiftEmit style closure or function (Event) -> ()
  */
  public func swiftEmitInt<T: SignedInteger>(_ ctx: T, keyPath:String, handler: @escaping Handler) {
    var context = T.init(0)
    swiftEmit(onKeyPath: keyPath, context: &context, handler: handler)
  }
  
  /**
   KVO for UInt8, UInt16, UInt32, etc
   
   Example:
   
        device.swiftEmitInt(UInt8(), keyPath: "myUInt8Var") { event in
          let x = (event as? Events.KVO)?.newValue as? Int
          print("The value is \(x)")
        }
   
   - Parameter T: An instance of the unsigned integer type, eg. UInt8(), UInt16()
   - Parameter keyPath: the KVO keypath
   - Parameter handler: a SwiftEmit style closure or function (Event) -> ()
  */
  public func swiftEmitUInt<U: UnsignedInteger>(_ ctx: U, keyPath:String, handler: @escaping Handler) {
    var context = U.init(-0)
    swiftEmit(onKeyPath: keyPath, context: &context, handler: handler)
  }
  
  public func swiftEmitFloat(_ keyPath:String, handler: @escaping Handler) {
    var context = Float()
    swiftEmit(onKeyPath: keyPath, context: &context, handler: handler)
  }
  
  public func swiftEmitBool(_ keyPath:String, handler: @escaping Handler) {
    var context = Bool()
    swiftEmit(onKeyPath: keyPath, context: &context, handler: handler)
  }
  
  /**
  swiftEmitInt, swiftEmitUInt, swiftEmitBool, etc all call this method after 
  creating a context of the desired type. If SwiftEmit does not have a helper 
  method for the type you need to observe, look at the source for swiftEmitFloat
  and swiftEmitBool for examples of how to create a new helper method for some
  new kvo type.
  */
  @discardableResult public func swiftEmit(onKeyPath kp:String,
    context: UnsafeMutableRawPointer,
    handler: @escaping Handler) -> AdaptorForNSKVO
  {
    let adaptor = AdaptorForNSKVO(
      observee: self,
      keyPath: kp,
      context: context)
    adaptor.on(Events.KVO.self, run: handler)
    return adaptor
  }
}

extension Events {
  public struct KVO {
    public let oldValue: AnyObject?
    public let newValue: AnyObject?
    public init(oldValue: AnyObject?, newValue: AnyObject?) {
      self.oldValue = oldValue
      self.newValue = newValue
    }
  }
}

open class AdaptorForNSKVO: SwiftEmitNS {
  
  let NullValue  = "__KVO_CHANGED_VALUE_WAS_NULL__"
  
  var context: UnsafeMutableRawPointer
  var keyPath: String
  var observee: NSObject
  var observing = false
  
  let options =  NSKeyValueObservingOptions([.new, .old])
  
  init(observee: NSObject,
    keyPath: String,
    context: UnsafeMutableRawPointer) {
    self.observee = observee
    self.keyPath = keyPath
    self.context = context
  }
  
  deinit {
    stopObserving()
  }
  
  @discardableResult open override func startObserving() -> Bool {
    guard !observing else { return false }
   
    observee.addObserver(self,
      forKeyPath: keyPath,
      options: options,
      context: context)
    
    observing = true
    
    return true
  }
  
  @discardableResult open override func stopObserving() -> Bool {
    guard observing else { return false }
    
    observee.removeObserver(self, forKeyPath: keyPath)
    observing = false
    
    return true
  }
  
  override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
    
    //print("=== Observe: \(keyPath)")
    
    guard keyPath == self.keyPath  && context == self.context else {
      return super.observeValue(forKeyPath: nil,
        of: object,
        change: change,
        context: context)
    }
    
    var oldVal: AnyObject?
    var newVal: AnyObject?
    if let c = change {
      if let ov = c[NSKeyValueChangeKey.oldKey] { oldVal = ov as AnyObject? }
      if let nv = c[NSKeyValueChangeKey.newKey] { newVal = nv as AnyObject? }
    }
    
    emit(Events.KVO(oldValue: oldVal, newValue: newVal))
  }
  
}
