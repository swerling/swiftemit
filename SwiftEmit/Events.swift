//
//  BaseEvent.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation

public class BasicEvent {
  public init() { } // this seems to be needed in order for SwiftEmit to be used as module. not sure why
}


/** 
  The Events class is for namespacing only for some stock event types.
  These events are mostly here for tests, and to provide typical usage of events.
*/
public class Events {
  
  /**
    Info about any value change
  */
  public struct ValueChange {
    public let oldValue: AnyObject
    public let value: AnyObject
    public let name: String?
    public init(oldValue: AnyObject, value: AnyObject, name: String? = nil) {
      self.oldValue = oldValue
      self.value = value
      self.name = name
    }
  }
  
  /**
    Info about any value about to change
  */
  public struct ValueWillChange {
    public let value: AnyObject!
    public let newValue: AnyObject!
    public let name: String?
    public init(value: AnyObject, newValue: AnyObject, name: String? = nil) {
      self.value = value
      self.newValue = newValue
      self.name = name
    }
  }
  
}



