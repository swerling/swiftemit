//
//  Example1Tests.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/19/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import XCTest
@testable import SwiftEmit


// Some example event payloads
struct ColorChange { var color: String }

struct RequestShapeValidation {
  var shape: Shape
}

// An example class that emits events
class Shape: Emitter {
  var color: String = "red" {
    didSet {
      let event = emit(RequestShapeValidation(shape: self))
      if let reason = event?.context["invalid"] as? String {
        self.color = oldValue
        print("Invalid: \(reason)")
      }
      else {
        emit(ColorChange(color: color))
      }
    }
  }
}

class Example1Tests: XCTestCase {
    
  override func setUp() {
    super.setUp()
  }
    
  override func tearDown() {
    super.tearDown()
  }
    
  func testExample1() {
    var shape = Shape()
    
    // Register handler for event using trailing closure syntax:
    shape.on(ColorChange.self) { event in
      guard let payload = event.payload as? ColorChange else { return }
      print("The new color for shape is \(payload.color)")
    }
    
    // Register handler for event by passing function
    func validateShape(event: Event) {
      guard let payload = event.payload as? RequestShapeValidation else { return }
      print("The proposed color for myObject is \(payload.shape.color)")
      if !["red", "blue", "green"].contains(payload.shape.color) {
        event.context["invalid"] = "Color is all wrong: \(payload.shape.color)"
      }
    }
    shape.on(RequestShapeValidation.self, run: validateShape)
    
    // Do something that fires an event
    shape.color = "purple"
    shape.color = "green"
  }
  
}
