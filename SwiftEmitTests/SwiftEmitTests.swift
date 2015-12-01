//
//  SwiftEmitTests.swift
//  SwiftEmitTests
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import XCTest
@testable import SwiftEmit

enum EnumEvent {
  case DidSet
  case WillSet
}

class TestEmitter: EmitterClass {
  var foo = "initial value of foo" {
    willSet {
      emit(Events.ValueWillChange(value: foo, newValue: newValue, name: "val"))
    }
    didSet {
      emit(Events.ValueChange(oldValue: oldValue, value: foo, name: "val"))
    }
  }
  var enumFoo = "initial value of enumFoo" {
    didSet {
      emit(EnumEvent.DidSet)
    }
  }
}
  
class SwiftEmitTests: XCTestCase {
  
  func testBasic() {
    // Emitters must be hashable. When building the Handlers map, object hashValues are used to apply events to handlers
    let emitter1 = TestEmitter()
    let emitter2 = TestEmitter()
    var will = "'will' not called yet"
    var will2 = "'will2' not called yet"
    var did = "'did' not called yet"
    
    func handler1(event: Event) {
      guard event is Events.ValueWillChange else { return }
      will = "handler 1 will fire"
    }
    
    emitter1.on(Events.ValueWillChange.self, run: handler1)
    emitter1.on(Events.ValueWillChange.self) { event in
      will2 = "handler 1 will fire twice"
    }
    emitter1.on(Events.ValueChange.self) { event in
      let event = event as? Events.ValueChange
      XCTAssert(event != nil,
        "Expected event to be ValueChangeEvent based on TestEmitter's didSet")
      did = "handler 1 did fire"
    }
    emitter1.foo = "hi"
    
    XCTAssert(will == "handler 1 will fire",
      "expected handler 1 willSet to emit Events.ValueWillChange. But 'will' is \(will)")
    XCTAssert(will2 == "handler 1 will fire twice",
      "expected handler 1 willSet to fire twice, since emitter was given 2 different on:handler: handlers. tests 2 handlers on same object and event type. But 'will2' is \(will2)")
    XCTAssert(did == "handler 1 did fire",
      "expected handler didSet to fire. tests 2 event types on one object. But 'did' is \(did)")
    
    emitter2.on(Events.ValueChange.self) { event in
      did = "handler 2 fired"
    }
    emitter2.foo = "hi"  // set off events for emitter 2
    XCTAssert(did == "handler 2 fired",
      "expected handler 2 to fire. tests object.hashValue -> Event.Type -> [Handler] map when you have different objects using same event type, make sure they are using different Handlers. 'did' is \(did)")

  }
  
  func testWithEnumEvent() {
    let emitter = TestEmitter() // ie. hashValue = 1
    var did = ""
    
    func didHandler(event: Event) {
      guard let event = event as? EnumEvent else {return}
      did = "did fired: \(event)"
    }
    
    emitter.on(EnumEvent.self, run: didHandler)
    emitter.enumFoo = "Hey"
    XCTAssert(did == "did fired: DidSet",
      "expected handler to fire with enum event EnumEvent.DidSet. Did: '\(did)'")
  }
  
  func testUnregister() {
    let emitter = TestEmitter()
    var will = ""
    var did = ""
    var did2 = ""
    emitter.on(Events.ValueChange.self) { event in
      did = "did changed"
    }
    emitter.on(Events.ValueChange.self) { event in
      did2 = "did2 changed"
    }
    emitter.on(Events.ValueWillChange.self) { event in
      will = "will changed"
    }
    SwiftEmitNS.startAll()
    emitter.foo = "hey"
    XCTAssert(did == "did changed",
      "Bad test setup, expected ValueChange handler to fire")
    XCTAssert(did2 == "did2 changed",
      "Bad test setup, expected ValueChange handler to fire")
    XCTAssert(will == "will changed",
      "Bad test setup, expected ValueWillChange handler to fire")
    
    // Now remove ValueChange event handlers. ValueWillChange should still fire
    did = ""
    did2 = ""
    will = ""
    emitter.removeEmitHandlers(Events.ValueChange.self)
    emitter.foo = "ho"
    XCTAssert(did == "",
      "Removed all ValueChange handlers, expected var to be unchanged")
    XCTAssert(did2 == "",
      "Removed all ValueChange handlers, expected var to be unchanged")
    XCTAssert(will == "will changed",
      "Removing ValueChange handlers should not effect ValueWillChange handler, expected ValueWillChange handler to fire and alter 'will'")
    
    // Now remove all the handlers, make sure events no longer fire
    did = ""
    did2 = ""
    will = ""
    emitter.removeAllEmitHandlers()
    emitter.foo = "ho"
    XCTAssert(did == "",
      "Removed all event handlers, expected var to be unchanged")
    XCTAssert(did2 == "",
      "Removed all event handlers, expected var to be unchanged")
    XCTAssert(will == "",
      "Removed all event handlers, expected var to be unchanged")
  }
  
  func testEventContext() {
    
    let emitter = TestEmitter()
    var proofHandlerFired = "did not fire yet"
    
    emitter.on(Events.ValueChange.self) { event in
      
      let event = event as? Events.ValueChange
      XCTAssert(event != nil,
        "Expected event to be ValueChangeEvent based on TestEmitter's didSet")
      
      proofHandlerFired = "handler did fire"
    }
    
    emitter.foo = "hi" // should trigger event
    
    XCTAssert(proofHandlerFired == "handler did fire",
      "just testing that handler fired at all. Main tests fo handler firing in testEventMap, since event context tests are inside of a handler")
  }
  
}
