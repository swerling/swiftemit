//
//  SwiftEmit.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation

// todo: make this generic, instead of forcing handlers to subclass Event.Base
typealias Handler = (Event.Base) -> ()

protocol Emitter {
  var eventHandlers: [SwiftEmit.Handler] { get }
}

extension Emitter {
  func emit(event: Event.Base) {
    event.emit(from: self, to: eventHandlers)
  }
}

// Subclasses are implemened as extenstions to Event
class Event { }





