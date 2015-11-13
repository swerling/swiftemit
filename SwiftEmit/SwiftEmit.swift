//
//  SwiftEmit.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation

// todo: make this generic, instead of forcing handlers to subclass Event.Base
public typealias Handler = (Event) -> ()

public protocol Emitter {
  var eventHandlers: [SwiftEmit.Handler] { get }
}

public struct EventInfo<T: Event> {
  var sender: AnyObject
  var startTime: NSDate
  var endTime: NSDate
  var payload: T
}

public extension Emitter {
  func emit(event: Event) {
    event.emit(from: self, to: eventHandlers)
  }
  
  
  /*
  func emitB(event: Event) {
    event.emit(from: self,
      to: EventMap.handlersFor(self, event: event))
    //event.emit(from: self, to: eventHandlers)
  }
  
  func handlersFor(object: AnyObject, event: Event) {
    
  }
*/
}

/*
class EventMap {
  typealias EventTypeLookup = [Event.Type: [Handler]]
  static var objectLookup = [AnyObject: EventTypeLookup]()
  static func add(object: AnyObject, event: Event, handler: Handler) {
    if objectLookup[object] == nil {
      objectLookup[object] = [EventTypeLookup]()
    }
    objectLookup[object][event.Type].append(handler)
  }
  static func handersFor(object: AnyObject, event: Event) {
    let typeLookup = map[object]
    
  }
}
*/
