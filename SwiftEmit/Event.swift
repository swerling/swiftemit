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
  var typeId: String {get}
  
  // this is what is forcing the protocol to be class only. There is probably a clean way to provide this info w/out the side-effect
  // clause in the emit method (see extension below). For now, this is how it is.
  var sender: Emitter? {get set}
  
  func emit(from sender: Emitter, to handlers: [Handler])
  
}

public extension Event {
  public func emit(from sender: Emitter, to handlers: [Handler]) {
    self.sender = sender
    for handler in handlers {
      handler(self)
    }
  }
}

public class BasicEvent: Event {
  public init() { } // this seems to be needed in order for SwiftEmit to be used as module. not sure why
  
  public var sender: Emitter?
  
  public var typeId: String {
    return "\(self.self)"
  }
  
}




