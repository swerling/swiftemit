//
//  Example1Tests.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/19/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import XCTest
@testable import SwiftEmit


// Some example events
struct ColorChange { var color: String }

class RequestShapeValidation {
  var shape: Shape
  var invalidReason: String?
  init(shape: Shape) {
    self.shape = shape
  }
}

// An example class that emits events
class Shape: EmitterClass {
  var color: String = "red" {
    didSet {
      let event = RequestShapeValidation(shape: self)
      emit(event)
      if event.invalidReason != nil {
        self.color = oldValue
        print("Invalid: \(event.invalidReason)")
      }
      else {
        emit(ColorChange(color: color))
      }
    }
  }
}

class Example1Tests: XCTestCase {
    
  func testExample1() {
    var shape = Shape()
    
    // Register handler for event using trailing closure syntax:
    shape.on(ColorChange.self) { event in
      guard let event = event as? ColorChange else { return }
      print("The new color for shape is \(event.color)")
    }
    
    // Register handler for event by passing function
    func validateShape(_ event: Event) {
      guard let event = event as? RequestShapeValidation else { return }
      print("The proposed color for myObject is \(event.shape.color)")
      if !["red", "blue", "green"].contains(event.shape.color) {
        event.invalidReason = "Color is all wrong: \(event.shape.color)"
      }
    }
    shape.on(RequestShapeValidation.self, run: validateShape)
    
    // Do something that fires an event
    shape.color = "purple" // -> RequestShapeValidation event vetos the change,
                           //    "Color is all wrong: purple"
    shape.color = "green"  // -> "The new color for shape is green"
  }
  
}
