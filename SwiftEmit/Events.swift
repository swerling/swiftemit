//
//  BaseEvent.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation

open class BasicEvent {
  public init() { } // this seems to be needed in order for SwiftEmit to be used as module. not sure why
}


/** 
  The Events class is for namespacing only for some stock event types.
  These events are mostly here for tests, and to provide typical usage of events.
*/
open class Events {
  
  /**
    Info about any value change
  */
  public struct ValueChange {
    public let oldValue: Any
    public let value: Any
    public let name: String?
    public init(oldValue: Any, value: Any, name: String? = nil) {
      self.oldValue = oldValue
      self.value = value
      self.name = name
    }
  }
  
  /**
    Info about any value about to change
  */
  public struct ValueWillChange {
    public let value: Any!
    public let newValue: Any!
    public let name: String?
    public init(value: Any, newValue: Any, name: String? = nil) {
      self.value = value
      self.newValue = newValue
      self.name = name
    }
  }
  
}



