//
//  BaseEvent.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation

// Really wanted to do this as a protocol, but my swift generics mojo not there yet
public protocol Event: class {
  
  // Used to lookup the class in a Hash. I will revisit in future rev, right now need this for handler lookup. Want to find a 
  // way to bind handlers to events in a proper swift/generic way instead of lookup up class names by self.self, but this works for now.
  static var typeId: String {get}
  
  //func emit<T: Emitter>(from sender: T, to handlers: [Handler])
  
}

/*
public extension Event {
  
  public func emit<T: Emitter>(from sender: T) -> EventInfo? {
    
    guard let handlers = EventMap.handlers(sender, event: self) else {
      return nil
    }
    
    let eventInfo = EventInfo(sender: self,
      startTime: NSDate(),
      endTime: nil,
      payload: self)
    
    for handler in handlers {
      handler(eventInfo)
    }
    
    return eventInfo

  }
}*/

public class BasicEvent: Event {
  public init() { } // this seems to be needed in order for SwiftEmit to be used as module. not sure why
  
  public static var typeId: String {
    return "\(self.self)"
  }
  
}




