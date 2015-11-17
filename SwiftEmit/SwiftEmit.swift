//
//  SwiftEmit.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation

public typealias Handler = (Event) -> ()
public typealias EventTypeId = String

public struct Event {
  public var payload: Any
  public var context: [String: Any]
}

public protocol Emitter: Hashable {
  /**
   For the current Emitter, call handler when event with payload of given type are emitted.
   
   - parameter type: Event type. Any object can be payload for a SwiftEmit event.
   - parameter handler: a Handler, (EventInfo) -> (). Called when events with payload of given type are emitted.
   
   - returns: nada
   */
  func on(payloadType: Any.Type, run handler: Handler)
  func emit(payload: Any) -> Event?
}

/**
  Generic Emitter that emits events with payload Any.
  #emit Adds the following to the event's context:
    - "sender": the emitter firing the event
    - "startTime": timestamp just before event
    - "endTime": timestamp just after all handlers return
*/
public extension Emitter {
  
  public func on(payloadType: Any.Type, run handler: Handler) {
    EventMap.add(self, typeId: EventMap.typeId(payloadType), handler: handler)
  }
  
  /**
    Emit an event with the given payload.
    #emit Adds the following to the event's context:
      - "sender": the emitter firing the event
      - "startTime": timestamp just before event
      - "endTime": timestamp just after all handlers return
  */
  func emit(payload: Any)  -> Event? {
    
    guard let handlers = EventMap.handlers(self, payload: payload) else {
      return nil
    }
    
    var event = Event(
      payload: payload,
      context: ["startTime": NSDate() as Any,
                "sender": self as Any])
    
    for handler in handlers { handler(event) }
    
    event.context["endTime"] = NSDate() as Any
    return event
  }
  
}

// TODO: make ref to Handlers weak
private class EventMap {
  
  typealias EventTypeLookup = [EventTypeId: [Handler]]
  static var objectLookup = [Int: EventTypeLookup]()
  
  static func typeId(any: Any) -> EventTypeId {
    return typeId(any.dynamicType)
  }
  
  static func typeId(anyType: Any.Type) -> EventTypeId {
    return "\(anyType.self)"
  }
  
  static func add<T: Hashable>(object: T, typeId: EventTypeId, handler: Handler) {
    let ohash = object.hashValue
    if var eventTypeLookup = objectLookup[ohash] {
      if eventTypeLookup[typeId] != nil {
        objectLookup[ohash]?[typeId]?.append(handler)
      } else {
        objectLookup[ohash]?[typeId] = [handler]
      }
    } else {
      objectLookup[ohash] = [typeId: [handler]]
    }
    
    print("Added \(ohash)")
  }
  
  static func handlers<T: Emitter>(object: T, payload: Any) -> [Handler]? {
    let ohash = object.hashValue
    guard let eventTypeToHandlers = objectLookup[ohash] else { return nil }
    let typeid = typeId(payload)
    guard let handlers = eventTypeToHandlers[typeid] else { return nil }
    return handlers
  }
}