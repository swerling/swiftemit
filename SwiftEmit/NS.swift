//
//  NS.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation

// Eg. See NotificationCenterWrapper, CoreMotionWrapper, KVOWrapper
protocol NS {
  func startObserving()-> Bool
  func stopObserving()-> Bool
}