//
//  AnyKey.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/13/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation

// https://devforums.apple.com/message/1045616

struct AnyKey: Hashable {
  private let underlying: [Any]
  private let hashValueFunc: () -> Int
  private let equalityFunc: (Any) -> Bool
  
  init<T: Hashable>(_ key: T) {
    underlying = [key]
    // Capture the key's hashability and equatability using closures.
    // The Key shares the hash of the underlying value.
    hashValueFunc = { key.hashValue }
    
    // The Key is equal to a Key of the same underlying type,
    // whose underlying value is "==" to ours.
    equalityFunc = {
      if let other = $0 as? T {
        return key == other
      }
      return false
    }
  }
  
  var hashValue: Int { return hashValueFunc() }
}

func ==(x: AnyKey, y: AnyKey) -> Bool {
  return x.equalityFunc(y.underlying[0])
}