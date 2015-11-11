//
//  ValueChange.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation

extension Event {
  public class ValueChange: Event.Base {
    let oldValue: AnyObject?
    let newValue: AnyObject?
    let name: String?
    
    init(oldValue: AnyObject? = nil, newValue: AnyObject? = nil, name: String? = nil) {
      self.oldValue = oldValue
      self.newValue = newValue
      self.name = name
    }
    
  }
}

// Same as value change, but users can send this on willChange
extension Event {
  class ValueWillChange: Event.ValueChange { }
}