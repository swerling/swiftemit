//
//  NS.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation

// Eg. See NotificationCenterWrapper, CoreMotionWrapper, KVOWrapper
public class SwiftEmitNS: NSObject {
  
  public static var all = [SwiftEmitNS]()
  
  override init() {
    super.init()
    SwiftEmitNS.all.append(self)
  }
  
  public func startObserving()-> Bool {
    preconditionFailure("Subclasses must implement \(__FUNCTION__)")
  }
  public func stopObserving()-> Bool {
    preconditionFailure("Subclasses must implement \(__FUNCTION__)")
  }
  
}

