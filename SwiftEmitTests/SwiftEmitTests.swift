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
      emit(Payload.ValueWillChange(value: foo, newValue: newValue, name: "val"))
    }
    didSet {
      emit(Payload.ValueChange(oldValue: oldValue, value: foo, name: "val"))
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
    
    func handler1(event: Event) {
      guard event.payload is Payload.ValueWillChange else { return }
      will = "handler 1 will fire"
    }
    
    emitter1.on(Payload.ValueWillChange.self, run: handler1)
    emitter1.on(Payload.ValueWillChange.self) { event in
      will2 = "handler 1 will fire twice"
    }
    emitter1.on(Payload.ValueChange.self) { event in
      let payload = event.payload as? Payload.ValueChange
      XCTAssert(payload != nil,
        "Expected payload to be ValueChangeEvent based on TestEmitter's didSet")
      let sender = event.context["sender"] as? TestEmitter
      XCTAssert(sender != nil,
        "Expected content['sender'] to be emitter1")
      did = "handler 1 did fire"
    }
    emitter1.foo = "hi"
    
    XCTAssert(will == "handler 1 will fire",
      "expected handler 1 willSet to emit Payload.ValueWillChange. But 'will' is \(will)")
    XCTAssert(will2 == "handler 1 will fire twice",
      "expected handler 1 willSet to fire twice, since emitter was given 2 different on:handler: handlers. tests 2 handlers on same object and event type. But 'will2' is \(will2)")
    XCTAssert(did == "handler 1 did fire",
      "expected handler didSet to fire. tests 2 event types on one object. But 'did' is \(did)")
    
    emitter2.on(Payload.ValueChange.self) { event in
      did = "handler 2 fired"
    }
    emitter2.foo = "hi"  // set off events for emitter 2
    XCTAssert(did == "handler 2 fired",
      "expected handler 2 to fire. tests object.hashValue -> Event.Type -> [Handler] map when you have different objects using same event type, make sure they are using different Handlers. 'did' is \(did)")

  }
  
  func testEventContext() {
    
    let emitter = TestEmitter(h: 1)
    var proofHandlerFired = "did not fire yet"
    
    emitter.on(Payload.ValueChange.self) { event in
      
      let payload = event.payload as? Payload.ValueChange
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
  
  class FakeCamera: NSObject {
    dynamic var iso: Float = 200
  }
  
  func testKVO() {
    print("Hey now")
    let camera = FakeCamera()
    camera.iso = 200
    var proof:Float? = nil
    camera.swiftEmitFloat("iso") { event in
      guard let payload = event.payload as? Payload.KVO else { return }
      proof = payload.newValue as? Float
    }
    
    camera.iso = 300
    XCTAssert(proof == nil,
      "should NOT have gotten KVO event yet, did not yet SwiftEmitNS.startAll()")
    
    SwiftEmitNS.startAll()
    camera.iso = 400
    XCTAssert(proof == 400,
      "should have gotten KVO event setting fake camera iso to 400")
    
    // In following calls, doing multiple stopAll and startAll calls in a row because in SwiftEmit, calls to KVO addObserver and removeObserver are idempotent
    
    SwiftEmitNS.startAll()
    SwiftEmitNS.startAll()
    SwiftEmitNS.startAll()
    camera.iso = 400
    XCTAssert(proof == 400,
      "should have gotten KVO event setting fake camera iso to 400")
    
    SwiftEmitNS.stopAll()
    SwiftEmitNS.stopAll()
    SwiftEmitNS.stopAll()
    camera.iso = 500
    XCTAssert(proof == 400,
      "should NOT have gotten KVO event, did SwiftEmitNS.stopAll()")
    
    SwiftEmitNS.startAll()
    camera.iso = 700
    XCTAssert(proof == 700,
      "should have gotten KVO event setting fake camera iso to 700")
    
  }
  
  /*
  func testPerformanceExample() {
    measureBlock {
        // Put the code you want to measure the time of here.
    }
  }*/
    
}
