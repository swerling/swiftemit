//
//  NS.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation

// Eg. See NotificationCenterWrapper, CoreMotionWrapper, KVOWrapper
open class SwiftEmitNS: NSObject, EmitterClass {
  
  open static var all = [SwiftEmitNS]()
  
  open static func startAll() {
    SwiftEmitNS.all.forEach {ns in ns.startObserving()}
  }
  
  open static func stopAll() {
    SwiftEmitNS.all.forEach {ns in ns.stopObserving()}
  }
  
  override init() {
    super.init()
    SwiftEmitNS.all.append(self)
  }
  
  @discardableResult open func startObserving()-> Bool {
    preconditionFailure("Subclasses must implement \(#function)")
  }
  @discardableResult open func stopObserving()-> Bool {
    preconditionFailure("Subclasses must implement \(#function)")
  }
  
}

public func swiftEmitId(_ obj: SwiftEmitNS) -> Int {
  return obj.hashValue
}
