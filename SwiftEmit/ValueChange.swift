//
//  ValueChange.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation

public class ValueChangeEvent: BasicEvent  {
  public let oldValue: AnyObject?
  public let newValue: AnyObject?
  public let name: String?
  
  public init(oldValue: AnyObject? = nil, newValue: AnyObject? = nil, name: String? = nil) {
    self.oldValue = oldValue
    self.newValue = newValue
    self.name = name
  }
}

// Same as value change, but users can send this on willChange
public class ValueWillChangeEvent: ValueChangeEvent { }