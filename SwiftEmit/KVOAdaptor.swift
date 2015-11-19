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
          let x = (event.payload as? Payload.KVO)?.newValue as? Int
          print("The value is \(x)")
        }
   
   - Parameter T: An instance of the signed integer type, eg. Int8(), Int16()
   - Parameter keyPath: the KVO keypath
   - Parameter handler: a SwiftEmit style closure or function (Event) -> ()
  */
  public func swiftEmitInt<T: SignedIntegerType>(ctx: T, keyPath:String, handler: Handler) -> AdaptorForNSKVO?  {
    var context = T.init(0)
    return swiftEmit(onKeyPath: keyPath, context: &context, handler: handler)
  }
  
  /**
   KVO for UInt8, UInt16, UInt32, etc
   
   Example:
   
        device.swiftEmitInt(UInt8(), keyPath: "myUInt8Var") { event in
          let x = (event.payload as? Payload.KVO)?.newValue as? Int
          print("The value is \(x)")
        }
   
   - Parameter T: An instance of the unsigned integer type, eg. UInt8(), UInt16()
   - Parameter keyPath: the KVO keypath
   - Parameter handler: a SwiftEmit style closure or function (Event) -> ()
  */
  public func swiftEmitUInt<U: UnsignedIntegerType>(ctx: U, keyPath:String, handler: Handler) -> AdaptorForNSKVO?  {
    var context = U.init(-0)
    return swiftEmit(onKeyPath: keyPath, context: &context, handler: handler)
  }
  
  public func swiftEmitFloat(keyPath:String, handler: Handler) -> AdaptorForNSKVO? {
    var context = Float()
    return swiftEmit(onKeyPath: keyPath, context: &context, handler: handler)
  }
  
  public func swiftEmitBool(keyPath:String, handler: Handler) -> AdaptorForNSKVO? {
    var context = Bool()
    return swiftEmit(onKeyPath: keyPath, context: &context, handler: handler)
  }
  
  /**
  swiftEmitInt, swiftEmitUInt, swiftEmitBool, etc all call this method after 
  creating a context of the desired type. If SwiftEmit does not have a helper 
  method for the type you need to observe, look at the source for swiftEmitFloat
  and swiftEmitBool for examples of how to create a new helper method for some
  new kvo type.
  */
  public func swiftEmit(onKeyPath kp:String,
    context: UnsafeMutablePointer<Void>,
    handler: Handler) -> AdaptorForNSKVO
  {
    let adaptor = AdaptorForNSKVO(
      observee: self,
      keyPath: kp,
      context: context)
    adaptor.on(Payload.KVO.self, run: handler)
    return adaptor
  }
}

extension Payload {
  public struct KVO {
    public let oldValue: AnyObject?
    public let newValue: AnyObject?
    public init(oldValue: AnyObject?, newValue: AnyObject?) {
      self.oldValue = oldValue
      self.newValue = newValue
    }
  }
}

public class AdaptorForNSKVO: SwiftEmitNS {
  
  let NullValue  = "__KVO_CHANGED_VALUE_WAS_NULL__"
  
  var context: UnsafeMutablePointer<Void>
  var keyPath: String
  var observee: NSObject
  var observing = false
  
  let options =  NSKeyValueObservingOptions([.New, .Old])
  
  init(observee: NSObject,
    keyPath: String,
    context: UnsafeMutablePointer<Void>) {
    self.observee = observee
    self.keyPath = keyPath
    self.context = context
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
    
    emit(Payload.KVO(oldValue: oldVal, newValue: newVal))
  }
  
}