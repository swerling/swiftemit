# SwiftEmit

Observer pattern for Swift, with similarities to nodejs EventEmitters and 
smalltalk 'Announcements.'

Unifies and simplifies event handling for swift objects, NS KVO events, 
NSNotificationCenter events, etc.

Usage for NS KVO, NotificationCenter, and CoreMotion events 
shown further down.

To use swift emit on swift classes, you need to:
* Define some event payload types
* Emit instances of those payloads
* Create event handlers and bind them to events by payload type

##### Define some event payload types
```
class ColorChange {
  color: String
}
```

Payloads can be instances of Any type, but typically will
by objects (class instances), structs, or enum values. 

##### Emit instances of those payload types 

```
class MyClass: EmitterClass {
  func notifyColorChange() {
    emit(ColorChange(color: "red"))
    ...
```

For classes, adding the extension EmitterClass is enough to make it an Emitter.

Structs can be emitters too, by adding the 'Emitter' extension. 
But there is a little extra work and some gotchas on structs, so see [StructEmitterTests.swift](SwiftEmitTests/StructEmitterTests.swift) 
for an illustrative example.

##### Register event handlers

Register handlers for a given payload type like this:

```

// Using trailing closure...:

myEmitter.on(ColorChange.self) { event in
  guard let payload = event.payload as? ColorChange else { return }
  print("The new color for myObject is \(payload.color)")
}

// ...or by passing a function: 

func colorChanged(event: Event) {
  guard let payload = event.payload as? ColorChange else { return }
  print("The new color for myObject is \(payload.color)")
}
myEmitter.on(ColorChange.self, run: colorChanged)

```

##### NS KVO Events

There are adaptors for KVO and NotificationCenter events that use the same 
handler styles as above, eg:

```
  // KVO
  backCameraDevice.swiftEmitFloat { event in 
    guard let payload = event.payload as? SwiftEmit.Payload.KVO else { return }
    print("ISO Changed from \(payload.oldValue) -> \(payload.newValue) ")
  }

  // Notification center
  let ctr = NSNotificationCenter.defaultCenter()
  ctr.swiftEmit(UIAccessibilityGuidedAccessStatusDidChangeNotification) { event in
    self.handleGuidedAccessChange()
  }
```

There is also a CoreMotion adaptor (see examples below).

NOTE: call SwiftEmitNS.startAll() and stopAll() somewhere in your app to start/stop NS events. 

## Requirements

- Xcode 7.1+
- iOS 9.0+ 
- todo: not yet tested on Mac OS X 10.9+ / tvOS 9.0+ / watchOS 2.0+

## Features

* Observer pattern similar to nodejs Emitter, but...
* ...Emits objects (or structs) instead of string events (concept copied from 'Announcements' in smalltalk). Eg. see http://pharo.gemtalksystems.com/book/LanguageAndLibraries/announcements/
* Simple syntax to emit a payload, register/deregister event handlers
* Event contains: the payload, the context.  Handlers can side-effect the context 
(see examples below)
* Instances of Any can by payloads, typically class instances, structs, or enum values
* Adaptors for NS KVO, NotificationCenter, NSOperationQueue, where handlers take the same form as regular SwiftEmit events. (see examples below)

## More Examples

Handlers for SwiftEmit all take the form SwiftEmit.Handler:

```(SwiftEmit.Event) -> ()```

The handlers are the same form for KVO, CoreMotion, NotificationCenter and 
plain old swift objects and structs. (POSOAS?)

### KVO Events:

Example of observing the ISO value of a camera (a Float) on an iphone:

  ```
    camera.swiftEmitFloat { event in 
      guard let payload = event.payload as? Payload.KVO else { return }
      print("ISO Changed from \(payload.oldValue) -> \(payload.newValue) ")
    }

    // Eg. put in viewDidLoad and/or AppDelegate.applicationDidBecomeActive()
    SwiftEmitNS.startAll() 
    ...
    // Eg. put in AppDelegate.applicationWillResignActive()
    SwiftEmitNS.stopAll() 
  ```

Calls to SwiftEmitNS.startAll() and stopAll() are idempotent -- it will do no
harm to call them twice in a row, so various app awake and sleep events can be
hooked without worrying about crashing during registration/deregistration.

Compare to the standard Swift equivalent for example above:

    private var isoContext: Float = 1 
    ....
    camera.addObserver(self, 
      forKeyPath: "ISO",
      options: NSKeyValueObservingOptions.New,
      context: &isoContext)
    ...
    override func observeValueForKeyPath(keyPath: String,
      ofObject object: AnyObject, change: [NSObject : AnyObject],
      context: UnsafeMutablePointer<Void>) {
      if context == &isoContext {
        print("Change iso to \(keyPath)")
      }
    }
    ...
    camera.removeObserver(self, forKeyPath: "iso")

### Notification Center:

SwiftEmit:

    let ctr = NSNotificationCenter.defaultCenter()
    ctr.swiftEmit(UIAccessibilityGuidedAccessStatusDidChangeNotification) { event in
      self.handleGuidedAccessChange()
    }

(and dont forget SwiftEmitNS.startAll() and stopAll() somewhere in your app)

### Core Motion:

SwiftEmit:

   ```swift
    CMMotionManager().swiftEmit(updateInterval: NSTimeInterval(1.0)) { event in
      guard let payload = event.payload as? SwiftEmit.Payload.DeviceMotionEvent  else { return }

      guard payload.error == nil else {
        return warn("Process motion ns error: \(payload.error)")
      }
      guard let deviceMotion = payload.motion else {
        return warn("Process motion event contains neither motion nor error")
      }
      self.processMotion(deviceMotion)
    }
   ```

SwiftEmitNS.startAll() and stopAll() are needed for core motion too.

### Your Own Class

This example can be copy/pasted into an xcode 7.x playground. 

```
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

```

