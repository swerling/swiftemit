//: Playground - noun: a place where people can play

//import UIKit
import SwiftEmit

// Some example event payloads

struct ColorChange { var color: String }

struct RequestShapeValidation {
  var shape: Shape
}

// An example class that emits events. The RequestShapeValidation event will
// take advantage of the Event.context to veto a color change. The ColorChange
// event will be used to announce a successful color change

class Shape: ObjectEmitter {
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
print("Going to try purple")
shape.color = "purple" // -> RequestShapeValidation event vetos the change,
                       //    'validateShape' fires: "Color is all wrong: purple"
print("Going to try green")
shape.color = "green"  // -> "The new color for shape is green"