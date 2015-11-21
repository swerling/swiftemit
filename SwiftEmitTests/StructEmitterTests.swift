//
//  StructEmitTests.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/19/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import Foundation
import XCTest
@testable import SwiftEmit

class StructEmitTests: XCTestCase {

  // An example class that emits events (Equatable conformance func == 
  // implemented at bottom of this file). Note that Equatable and hashValue 
  // only take 'sides' in to account, ignoring color, making swift emit
  // act like a classification event
  struct Shape: Emitter {
    var sides = 3 {
      didSet {
        emit(ShapeChange(shape: self))
      }
    }
    var color = "red"
    
    // Based on this, from the perspective of SwiftEmit, structs are identified
    // (or maybe 'categorized') by virtue of their number of sides. So when the
    // sides var is set above to x, the handler that fires depends on which handler
    // was mapped to a struct with x sides
    func swiftEmitId() -> Int {
      return sides
    }
    
  }

  struct ShapeChange { var shape: Shape }

  override func setUp() {
    super.setUp()
  }
    
  override func tearDown() {
    super.tearDown()
  }
    
  func testStructEmit() {
    func handleShapeChange(sides: Int, _ event: Event) {
      guard let payload = event.payload as? ShapeChange else { return }
      print("\(payload.shape.color) shape fired register\(sides)SidedShape")
    }
    func beA3SidedShape(event: Event) { handleShapeChange(3, event) }
    func beA4SidedShape(event: Event) { handleShapeChange(4, event) }
    func beA5SidedShape(event: Event) { handleShapeChange(5, event) }
    
    var redShape = Shape(sides: 3, color: "red")
    var greenShape = Shape(sides: 4, color: "green")
    var blueShape = Shape(sides: 5, color: "blue")
    
    // Register handler for event using trailing closure syntax:
    Shape(sides: 3, color: "red").on(ShapeChange.self, run: beA3SidedShape)
    Shape(sides: 4, color: "red").on(ShapeChange.self, run: beA4SidedShape)
    Shape(sides: 5, color: "red").on(ShapeChange.self, run: beA5SidedShape)
    
    // Counterintuitive, but when structs chage, they are changing which
    // handlers are associated with them. Structs are values, not refs, and
    // changing their attributes changes there identity:
    
    redShape.sides = 3 // Fires beA3SidedShape
    greenShape.sides = 3 // Fires beA3SidedShape
    blueShape.sides = 3 // Fires beA3SidedShape
    
    redShape.sides = 4 // Fires beA4SidedShape
    greenShape.sides = 4 // Fires beA4SidedShape
    blueShape.sides = 4 // Fires beA4SidedShape
    
    redShape.sides = 5 // Fires beA5SidedShape
    greenShape.sides = 5 // Fires beA5SidedShape
    blueShape.sides = 5 // Fires beA5SidedShape
  }
  
  
}

// Emitter must be Hashable and thus Equatable
func ==(x: StructEmitTests.Shape, y: StructEmitTests.Shape) -> Bool {
  return x.sides == y.sides
}