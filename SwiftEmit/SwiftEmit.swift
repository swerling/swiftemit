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

public extension Emitter {
  func emit(event: Event) {
    event.emit(from: self, to: eventHandlers)
  }
}

