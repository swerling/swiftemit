//
//  SwiftEmit.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation

// todo: make this generic, instead of forcing handlers to subclass Event.Base
public typealias Handler = (EventInfo) -> ()

public typealias EventTypeId = String

public protocol Emitter: Hashable {
  func on(eventId: EventTypeId, handler: Handler)
  func emit(event: Event) -> EventInfo?
}

public struct EventInfo {
  var sender: AnyObject
  var startTime: NSDate
  var endTime: NSDate?
  var payload: Event
}

public extension Emitter {
  
  public func on<T: Event>(type: T, handler: Handler) {
    return on(T.typeId, handler: handler)
  }
  
  public func on(eventId: EventTypeId, handler: Handler) {
    EventMap.add(self, eventId: eventId, handler: handler)
  }
  
  func emit(event: Event)  -> EventInfo? {
    
    guard let handlers = EventMap.handlers(self, event: event) else {
      return nil
    }
    
    guard let sender = self as? AnyObject else { return nil }
    var eventInfo = EventInfo(sender: sender,
      startTime: NSDate(),
      endTime: nil,
      payload: event)
    
    for handler in handlers {
      handler(eventInfo)
    }
    
    eventInfo.endTime = NSDate()
    return eventInfo
  }
  
}

class EventMap {
  typealias EventTypeLookup = [EventTypeId: [Handler]]
  static var objectLookup = [Int: EventTypeLookup]()
  
  static func add<T: Hashable>(object: T, eventId: EventTypeId, handler: Handler) {
    let ohash = object.hashValue
    if var eventTypeLookup = objectLookup[ohash] {
      if eventTypeLookup[eventId] != nil {
        objectLookup[ohash]?[eventId]?.append(handler)
      } else {
        objectLookup[ohash]?[eventId] = [handler]
      }
    } else {
      objectLookup[ohash] = [eventId: [handler]]
    }
    
    print("Added \(ohash)")
  }
  
  static func handlers<T: Emitter>(object: T, event: Event) -> [Handler]? {
    let ohash = object.hashValue
    guard let eventTypeToHandlers = objectLookup[ohash] else { return nil }
    guard let handlers = eventTypeToHandlers[event.dynamicType.typeId] else { return nil }
    return handlers
  }
}