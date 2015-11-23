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

/*
public func swiftEmitId(obj: AnyObject) -> Int {
  return ObjectIdentifier(obj).hashValue
}

public func swiftEmitId(obj: Any) -> Int {
  return 1
}
*/

public class Event {
  public var payload: Any
  public typealias ContextDict = [String: Any]
  public var context: ContextDict
  public init(payload: Any, context: ContextDict = ContextDict()) {
    self.payload = payload
    self.context = context
  }
}

public protocol Emitter {
  func swiftEmitId() -> Int
  
  /**
   For the current Emitter, call handler when event with payload of given type are emitted.
   
   - parameter type: Event type. Any object can be payload for a SwiftEmit event.
   - parameter handler: a Handler, (EventInfo) -> (). Called when events with payload of given type are emitted.
   
   - returns: nada
   */
  func on(payloadType: Any.Type, run handler: Handler)
  
  /**
   Fire an event with the given payload. Will return an event containing the 
   payload and the filled in event context. 
   
   Handlers may choose to side effect the context in arbitrary fashion. The Emitter will typically put things like 'sender', 'startTime', 'endTime' in the context (it's up to the Emitter).
   
   - parameter payload: Any. Typically a type or struct that can be interrogated
   
   - returns: an Event (containing the payload and the event context).
   */
  func emit(payload: Any) -> Event?
  func removeAllEmitHandlers()
  func removeEmitHandlers(payloadType: Any.Type)
  
  /**
  Like hashValue, for swiftEmit. For AnyObject (class objects), this is already
  done, and uses the ObjectIdentifier(object).hashValue. For Structs, you 
  have to implment this.
  */
  //func swiftEmitId<T>(T: Any) -> Int
  //func swiftEmitId(obj: Self) -> Int
}


/**
  Generic Emitter that emits events with payload Any.
 
  #emit Adds the following to the event's context:
    - "sender": the emitter firing the event
    - "startTime": timestamp just before event
    - "endTime": timestamp just after all handlers return
*/

public extension Emitter {
  
  /**
  Register an event handler.
 
  Any function or closure conforming to type Handler can be a handler:
   
        (Event) -> ()
  
  Example:
   
       // example of passing a function
       myObject.on(ToggleActive.self, run: didToggleActive)
     
       // example of passing a closure using trailing closure syntax
       myObject.on(ToggleActive.self) { event in
         guard let payload = event.payload as ToggleActive else { return }
         if payload.active { 
           someLabel.text = "It's on!"
         } else {
           someLabel.text = ""
         }
       }
   
  - Parameter payloadType: A class or struct (not an instance, but the class itself, eg. MyPayloadClass.self, or MyPayloadStruct.self)
 
  - Parameter handler: A closure or function with sig (Event) -> ()
   
  - Returns: void
   
  */
  public func on(payloadType: Any.Type, run handler: Handler) {
    EventMap.add(self, typeId: EventMap.typeId(payloadType), handler: handler)
  }
  
  /**
  Emit an event with the given payload.
 
  Emit Adds the following to the event's context:
    * "sender": the emitter firing the event
    * "startTime": timestamp just before event
    * "endTime": timestamp just after all handlers return
 
  Example:
 
       emit(SomePayloadStructOrClass())
 
       emit(SwiftEmit.Payload.ValueChange(oldValue: oldValue,
                                          value: myvar,
                                          name: 'myvar'))
 - Parameter payload: Just about anything you want can be a payload. Typically an instance of a class or struct.
 
 - Returns: if successful, an Event object with the payload, and the context filled in with "sender", "startTime", "endTime". if unsuccessful, nil.
   
  */
  func emit(payload: Any)  -> Event? {
    
    guard let handlers = EventMap.handlers(self, payload: payload) else {
      return nil
    }
    
    let event = Event(
      payload: payload,
      context: ["startTime": NSDate() as Any,
                "sender": self as Any])
    
    for handler in handlers { handler(event) }
    
    event.context["endTime"] = NSDate() as Any
    return event
  }
  
  public func removeAllEmitHandlers() {
    EventMap.removeAll(self)
  }
  
  public func removeEmitHandlers(payloadType: Any.Type) {
    EventMap.remove(self, typeId: EventMap.typeId(payloadType))
  }
  
}

// just to juxtapose to ObjectEmitter
public typealias EmitterStruct = Emitter

// Plain old emitter, but with a default swiftEmitId based on the ObjectIdentifier
public protocol EmitterClass: class, Emitter { }
public extension EmitterClass {
  public func swiftEmitId() -> Int{
    return ObjectIdentifier(self).hashValue
  }
}

private class EventMap {
  
  typealias EventTypeLookup = [EventTypeId: [Handler]]
  static var objectLookup = [Int: EventTypeLookup]()
  
  static func typeId(any: Any) -> EventTypeId {
    return typeId(any.dynamicType)
  }
  
  static func typeId(anyType: Any.Type) -> EventTypeId {
    return "\(anyType.self)"
  }
  
  static func removeAll<T: Emitter>(object: T) {
    let ohash = object.swiftEmitId()
    objectLookup[ohash] = nil
  }
  
  static func remove<T: Emitter>(object: T, typeId: EventTypeId) {
    let ohash = object.swiftEmitId()
    objectLookup[ohash]?[typeId] = nil
  }
  
  static func add<T: Emitter>(object: T, typeId: EventTypeId, handler: Handler) {
    let ohash = object.swiftEmitId()
    if var eventTypeLookup = objectLookup[ohash] {
      if eventTypeLookup[typeId] != nil {
        objectLookup[ohash]?[typeId]?.append(handler)
      } else {
        objectLookup[ohash]?[typeId] = [handler]
      }
    } else {
      objectLookup[ohash] = [typeId: [handler]]
    }
    
    // print("Added \(ohash)")
  }
  
  static func handlers<T: Emitter>(object: T, payload: Any) -> [Handler]? {
    let ohash = object.swiftEmitId()
    guard let eventTypeToHandlers = objectLookup[ohash] else { return nil }
    let typeid = typeId(payload)
    guard let handlers = eventTypeToHandlers[typeid] else { return nil }
    return handlers
  }
}