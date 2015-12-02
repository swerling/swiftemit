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
public typealias Event = Any

public protocol Emitter {
  func swiftEmitId() -> Int
  func on(eventType: Any.Type, run handler: Handler)
  func emit(event: Event)
  func removeAllEmitHandlers()
  func removeEmitHandlers(eventType: Any.Type)
}


/**
  Generic Emitter that emits Events.
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
         guard let event = event as ToggleActive else { return }
         if event.active {
           someLabel.text = "It's on!"
         } else {
           someLabel.text = ""
         }
       }
   
  - Parameter eventType: A class or struct (not an instance, but the class itself, eg. MyEventClass.self, or MyEventStruct.self)
 
  - Parameter handler: A closure or function with sig (Event) -> ()
   
  - Returns: void
   
  */
  public func on(eventType: Any.Type, run handler: Handler) {
    EventMap.add(self, typeId: EventMap.typeId(eventType), handler: handler)
  }
  
  /**
  Emit an event.
 
  Example:
 
       emit(SomeEventStructOrClass())
 
       emit(SwiftEmit.Events.ValueChange(oldValue: oldValue,
                                          value: myvar,
                                          name: 'myvar'))
   - Parameter event: Just about anything you want can be an event. Typically an instance of a class or a struct.
  */
  func emit(event: Event) {
    guard let handlers = EventMap.handlers(self, event: event) else {
      return
    }
    for handler in handlers { handler(event) }
  }
  
  public func removeAllEmitHandlers() {
    EventMap.removeAll(self)
  }
  
  public func removeEmitHandlers(eventType: Any.Type) {
    EventMap.remove(self, typeId: EventMap.typeId(eventType))
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
  
  static func handlers<T: Emitter>(object: T, event: Event) -> [Handler]? {
    let ohash = object.swiftEmitId()
    guard let eventTypeToHandlers = objectLookup[ohash] else { return nil }
    let typeid = typeId(event)
    guard let handlers = eventTypeToHandlers[typeid] else { return nil }
    return handlers
  }
}