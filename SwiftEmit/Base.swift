//
//  BaseEvent.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation

// Really wanted to do this as a protocol, but my swift generics mojo not there yet
extension Event {
  public class Base {
    var sender: Emitter?
    
    func emit(from sender: Emitter, to handlers: [Handler]) {
      self.sender = sender
      for handler in handlers {
        handler(self)
      }
    }
    
  }
}