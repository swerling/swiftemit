//
//  SwiftEmitTests.swift
//  SwiftEmitTests
//
//  Created by Steven Swerling on 11/11/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import XCTest
@testable import SwiftEmit

class SwiftEmitTests: XCTestCase {
  
  class TestEmitter: Emitter {
    init() {}
    var eventHandlers = [Handler]()
    var active = false {
      didSet {
        emit(ValueChangeEvent(oldValue: oldValue, newValue: active))
      }
    }
  }
  
  /*
  override func setUp() {
    super.setUp()
  }
  
  override func tearDown() {
    super.tearDown()
  }*/
  
  func testValueChangeEvent() {
    let emitter = TestEmitter()
    var b = false
    emitter.active = false
    emitter.eventHandlers.append({ event in
      guard let event = event as? ValueChangeEvent else {return}
      b = event.newValue as! Bool // does this suck?
    })
    emitter.active = true  // should fire ValueChangeEvent, setting b
    XCTAssert(b, "expected event handler to set var to true")
  }
  
  
  /*
  func testPerformanceExample() {
    measureBlock {
        // Put the code you want to measure the time of here.
    }
  }*/
    
}
