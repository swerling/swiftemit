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
  var val = 0 {
    willSet {
      emit(ValueWillChangeEvent(oldValue: val, newValue: newValue, name: "val"))
    }
    didSet {
      emit(ValueChangeEvent(oldValue: oldValue, newValue: val, name: "val"))
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
  
  func testValueChangeEvent() {
    let emitter1 = TestEmitter(h: 1)
    let emitter2 = TestEmitter(h: 2)
    var will = ""
    var will2 = ""
    var did = ""
    
    emitter1.on(ValueWillChangeEvent.self) { eventInfo in
      guard eventInfo.payload is ValueWillChangeEvent else { return }
      will = "handler 1 will fire"
    }
    emitter1.on(ValueWillChangeEvent.self) { eventInfo in
      will2 = "handler 1 will fire twice"
    }
    emitter1.on(ValueChangeEvent.self) { eventInfo in
      guard eventInfo.payload is ValueChangeEvent else { return }
      did = "handler 1 did fire"
    }
    emitter1.val = 1  // should fire ValueChangeEvent, setting b
    XCTAssert(will == "handler 1 will fire", "expected handler 1 willSet to fire. 'will' is \(will)")
    XCTAssert(will2 == "handler 1 will fire twice", "expected handler 1 willSet to fire twice. tests 2 handlers on same object and event type. 'will2' is \(will2)")
    XCTAssert(did == "handler 1 did fire", "expected handler didSet to fire. tests 2 event types on one object. 'did' is \(did)")
    
    emitter2.on(ValueChangeEvent.self) { eventInfo in
      will = "handler 2 will fire"
    }
    emitter2.val = 1  // should fire ValueChangeEvent, setting b
    XCTAssert(will == "handler 2 will fire", "expected handler 2 to fire. tests similar event type firing on different objects. will is \(will)")

  }
  
  
  /*
  func testPerformanceExample() {
    measureBlock {
        // Put the code you want to measure the time of here.
    }
  }*/
    
}
