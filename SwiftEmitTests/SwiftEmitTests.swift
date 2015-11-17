//
//  SwiftEmitTests.swift
//  SwiftEmitTests
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import XCTest
@testable import SwiftEmit

class TestEmitter: Emitter {
  init(h: Int) { hashValue = h}
  var hashValue: Int = 0
  var eventHandlers = [Handler]()
  var foo = "initial value of foo" {
    willSet {
      emit(ValueWillChangeEvent(oldValue: foo, newValue: newValue, name: "val"))
    }
    didSet {
      emit(ValueChangeEvent(oldValue: oldValue, newValue: foo, name: "val"))
    }
  }
}
  
func ==(x: TestEmitter, y: TestEmitter) -> Bool {
  return x.hashValue == y.hashValue
}

class SwiftEmitTests: XCTestCase {
  
  /*
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }*/
  
  
  func testEventMap() {
    // Emitters must be hashable. When building the Handlers map, object hashValues are used to apply events to handlers
    let emitter1 = TestEmitter(h: 1) // ie. hashValue = 1
    let emitter2 = TestEmitter(h: 2) // ie. hashValue = 2
    var will = "'will' not called yet"
    var will2 = "'will2' not called yet"
    var did = "'did' not called yet"
    
    func handler1(eventInfo: Event) {
      guard eventInfo.payload is ValueWillChangeEvent else { return }
      will = "handler 1 will fire"
    }
    
    emitter1.on(ValueWillChangeEvent.self, handler: handler1)
    emitter1.on(ValueWillChangeEvent.self) { eventInfo in
      will2 = "handler 1 will fire twice"
    }
    emitter1.on(ValueChangeEvent.self) { event in
      let payload = event.payload as? ValueChangeEvent
      XCTAssert(payload != nil, "Expected payload to be ValueChangeEvent based on TestEmitter's didSet")
      let sender = event.context["sender"] as? TestEmitter
      XCTAssert(sender != nil, "Expected content['sender'] to be emitter1")
      did = "handler 1 did fire"
    }
    emitter1.foo = "hi"
    
    XCTAssert(will == "handler 1 will fire",
      "expected handler 1 willSet to emit ValueWillChangeEvent. But 'will' is \(will)")
    XCTAssert(will2 == "handler 1 will fire twice",
      "expected handler 1 willSet to fire twice, since emitter was given 2 different on:handler: handlers. tests 2 handlers on same object and event type. But 'will2' is \(will2)")
    XCTAssert(did == "handler 1 did fire",
      "expected handler didSet to fire. tests 2 event types on one object. But 'did' is \(did)")
    
    emitter2.on(ValueChangeEvent.self) { eventInfo in
      did = "handler 2 fired"
    }
    emitter2.foo = "hi"  // set off events for emitter 2
    XCTAssert(did == "handler 2 fired", "expected handler 2 to fire. tests object.hashValue -> Event.Type -> [Handler] map when you have different objects using same event type, make sure they are using different Handlers. 'did' is \(did)")

  }
  
  func testEventContext() {
    
    let emitter = TestEmitter(h: 1)
    var proofHandlerFired = "did not fire yet"
    
    emitter.on(ValueChangeEvent.self) { event in
      
      let payload = event.payload as? ValueChangeEvent
      XCTAssert(payload != nil,
        "Expected payload to be ValueChangeEvent based on TestEmitter's didSet")
      
      let sender = event.context["sender"] as? TestEmitter
      XCTAssert(sender != nil,
        "Expected content['sender'] to be emitter1")
      
      proofHandlerFired = "handler did fire"
    }
    
    emitter.foo = "hi" // should trigger event
    
    XCTAssert(proofHandlerFired == "handler did fire",
      "just testing that handler fired at all. Main tests fo handler firing in testEventMap, since event context tests are inside of a handler")
  }
  
  /*
  func testPerformanceExample() {
    measureBlock {
        // Put the code you want to measure the time of here.
    }
  }*/
    
}
