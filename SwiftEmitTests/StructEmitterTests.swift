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

  // An example struct that emits events (Equatable conformance func ==
  // implemented at bottom of this file). The Emitter protocol requires
  // implementation of swiftEmitId, see below.
  struct Shape: Emitter {
    var sides = 3 {
      didSet {
        emit(ShapeChange(shape: self))
      }
    }
    var color = "red"
    
    // Based on this swiftEmitId, from the perspective of SwiftEmit, structs are 
    // identified (or maybe 'categorized') by virtue of their number of sides.
    // So when the sides var is set above to x, the handler that fires depends 
    // on which handler was mapped to a struct with x sides. Confusing, but
    // with structs, you are effectively changing the identity of the value
    // when you change one of it's attribues. You can see the consequences of
    // this in below in testStructEmit()
    func swiftEmitId() -> Int {
      return sides
    }
    
  }

  struct ShapeChange { var shape: Shape }

  func testStructEmit() {
    func handleShapeChange(_ sides: Int, _ event: Event) {
      guard let event = event as? ShapeChange else { return }
      print("\(event.shape.color) shape fired register\(sides)SidedShape")
    }
    func beA3SidedShape(_ event: Event) { handleShapeChange(3, event) }
    func beA4SidedShape(_ event: Event) { handleShapeChange(4, event) }
    func beA5SidedShape(_ event: Event) { handleShapeChange(5, event) }
    
    var redShape = Shape(sides: 3, color: "red")
    var greenShape = Shape(sides: 4, color: "green")
    var blueShape = Shape(sides: 5, color: "blue")
    
    // Register handler for event using trailing closure syntax:
    redShape.on(ShapeChange.self, run: beA3SidedShape)
    greenShape.on(ShapeChange.self, run: beA4SidedShape)
    blueShape.on(ShapeChange.self, run: beA5SidedShape)
    
    // Now here is the catch. When structs chage, they are changing which
    // handlers are associated with them because -- structs are values, 
    // not refs, and changing their attributes changes there identity
    
    greenShape.sides = 3 // Fires beA3SidedShape. But greenShape was mapped to
      // fire beA4SidedShape! Doesn't matter, it's now a 3-sided shape, and thus
      // fires events mapped for 3-sided shapes, since the Shape struct's 
      // swiftEmitId is derived only from the number of sides.
    blueShape.sides = 3 // Fires beA3SidedShape
    redShape.sides = 3 // Fires beA3SidedShape
    
    greenShape.sides = 4 // Fires beA4SidedShape
    blueShape.sides = 4 // Fires beA4SidedShape
    redShape.sides = 4 // Fires beA4SidedShape
    
    greenShape.sides = 5 // Fires beA5SidedShape
    blueShape.sides = 5 // Fires beA5SidedShape
    redShape.sides = 5 // Fires beA5SidedShape
  }
  
  
}
