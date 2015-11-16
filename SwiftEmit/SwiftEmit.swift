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
  func on(typeId: AnyObject.Type, handler: Handler)
  func emit(event: AnyObject) -> EventInfo?
}

public struct EventInfo {
  var sender: AnyObject
  var startTime: NSDate
  var endTime: NSDate?
  var payload: AnyObject
}

public extension Emitter {
  
  public func on(type: AnyObject.Type, handler: Handler) {
    let typeid = EventMap.typeId(type) // bad?
    EventMap.add(self, typeId: typeid, handler: handler)
  }
  
  func emit(event: AnyObject)  -> EventInfo? {
    
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
  
  static func typeId(obj: AnyObject) -> EventTypeId {
    return typeId(obj.dynamicType)
  }
  
  static func typeId(type: AnyObject.Type) -> EventTypeId {
    return "\(type.self)"
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
  
  static func handlers<T: Emitter>(object: T, event: AnyObject) -> [Handler]? {
    let ohash = object.hashValue
    guard let eventTypeToHandlers = objectLookup[ohash] else { return nil }
    //let typeid = "\(event.dynamicType.self)"
    let typeid = typeId(event)
    guard let handlers = eventTypeToHandlers[typeid] else { return nil }
    return handlers
  }
}