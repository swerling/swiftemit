//: Playground - noun: a place where people can play

import SwiftEmit

// Some example event types. Instances of these will be emitted as event.payloads

struct ColorChange { var color: String }

struct RequestShapeValidation {
  var shape: Shape
}

// An example class that emits events. The RequestShapeValidation event will
// take advantage of the Event.context to allow associated handlers to veto
// a color change. The ColorChange event will be used to announce a successful
// color change.

class Shape: EmitterClass {
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

// Ok, event emitters done. Now lets create an object and give it some
// Event handlers
var shape = Shape()

// This one will announce the change of shape's color (using trailing closure
// syntax for mapping):
shape.on(ColorChange.self) { event in
  guard let payload = event.payload as? ColorChange else { return }
  print("The new color for shape is \(payload.color)")
}

// Declare invalid any color change that is not red, blue, or green.
// This one shows how to register a handler for an event by passing a function
// (as opposed to using trailing closure syntax)
func validateShape(event: Event) {
  guard let payload = event.payload as? RequestShapeValidation else { return }
  
  print("The proposed color for myObject is \(payload.shape.color)")
  
  if !["red", "blue", "green"].contains(payload.shape.color) {
    event.context["invalid"] = "Color is all wrong: \(payload.shape.color)"
  }
  
}
shape.on(RequestShapeValidation.self, run: validateShape)

// Change the color to something invalid. The validateShape function
// will reject it: "Color is all wrong: purple"
print("Going to try purple")
shape.color = "purple" // validateShape: "Color is all wrong: purple"
print(shape.color) // It's still red

// Change the color to green
// The closure listening for ColorChange events will announce that
// "The new color for shape is green"
print("Going to try green")
shape.color = "green"  // -> "The new color for shape is green"
print(shape.color) // It's now green