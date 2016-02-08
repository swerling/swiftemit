# SwiftEmit

Observer pattern for Swift, with similarities to nodejs EventEmitters and 
to Smalltalk 'Announcements.'

Unifies and simplifies event handling for NS KVO events, 
NSNotificationCenter events, and plain old Swift objects and structs.

##### Usage 

Cliffnotes version. More detailed examples below.

* Define some event types 

    ```
    // Any class instance, struct instance, or Enum value can be an event.
    class ColorChange {
      color: String
    }
    ```

* Create handlers for those events

    ```
    // Using trailing closure...:
    myEmitter.on(ColorChange.self) { event in
      guard let event = event as? ColorChange else { return }
      print("The new color for myObject is \(event.color)")
    }

    // ...or by passing a function reference: 
    func colorChanged(event: Event) {
      guard let event = event as? ColorChange else { return }
      print("The new color for myObject is \(event.color)")
    }
    myEmitter.on(ColorChange.self, run: SomeClass.colorChanged)

    ```

* Emit those events

    ```
    class MyClass: EmitterClass {
      func notifyColorChange() {
        emit(ColorChange(color: "red"))
        ...
    ```

* For classes, adding the extension EmitterClass is enough to make it a SwiftEmit Emitter.
* Structs can be emitters too, by adding the 'Emitter' extension. But there is a little extra work and some gotchas on structs, so see [StructEmitterTests.swift](SwiftEmitTests/StructEmitterTests.swift) 
for an illustrative example.

##### NS KVO Events

There are adaptors for KVO and NotificationCenter events that use the same 
handler styles as above, eg:

  ```
  // KVO
  backCameraDevice.swiftEmitFloat { event in 
    guard let event = event as? SwiftEmit.Events.KVO else { return }
    print("ISO Changed from \(event.oldValue) -> \(event.newValue) ")
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
* ...Emits class or struct instances (or enum values) instead of string events. Concept copied from 'Announcements' in smalltalk, Eg. see http://pharo.gemtalksystems.com/book/LanguageAndLibraries/announcements/
* Simple syntax to emit an event, register/deregister event handlers
* Adaptors for NS KVO, NotificationCenter, NSOperationQueue, where handlers take the same form as regular SwiftEmit events. (See examples below.)

## More Examples

Handlers for SwiftEmit all take the form SwiftEmit.Handler:

```(SwiftEmit.Event) -> ()```

The handlers are the same form for KVO, CoreMotion, NotificationCenter and 
plain old swift class or struct instances. (POSCOSI?)

### KVO Events:

Example of observing the ISO value of a camera (a Float) on an iphone:

  ```
    camera.swiftEmitFloat { event in 
      guard let event = event as? Events.KVO else { return }
      print("ISO Changed from \(event.oldValue) -> \(event.newValue) ")
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
        if let newValue = change?[NSKeyValueChangeNewKey] {
          print("Change iso to \(newValue)")
        }
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

   ```
    CMMotionManager().swiftEmit(
      motionManager: CMMotionManager(),
      queue: NSOperationQueue.currentQueue(),
      updateInterval: NSTimeInterval(1.0)) { event in

      guard let event = event as? SwiftEmit.Events.DeviceMotionEvent  else { return }

      guard event.error == nil else {
        return warn("Process motion ns error: \(event.error)")
      }

      guard let deviceMotion = event.motion else {
        return warn("Process motion event contains neither motion nor error")
      }

      self.processMotion(deviceMotion)
    }
   ```
All of the params to CMMotionManager.swiftEmit() are optional.

SwiftEmitNS.startAll() and stopAll() are needed for core motion too.

### Your Own Class

This example can be copy/pasted into an xcode 7.x playground. 

```
import SwiftEmit

// Some example event types. Instances of these will be emitted as events.

struct ColorChange { var color: String }

class RequestShapeValidation {
  var shape: Shape
  var invalidReason: String?
  init(shape: Shape) {
    self.shape = shape
  }
}

// An example class that emits events. If one of the RequestShapeValidation
// handlers puts something in 'invalidReason', the value is rolled back.
// If not, the ColorChange event will be used to announce a successful
// color change.

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

// Ok, event emitters done. Now lets create an object and give it some
// Event handlers
var shape = Shape()

// This one will announce the change of shape's color (using trailing closure
// syntax for mapping):
shape.on(ColorChange.self) { event in
  guard let event = event as? ColorChange else { return }
  print("The new color for shape is \(event.color)")
}

// Declare invalid any color change that is not red, blue, or green.
// This one shows how to register a handler for an event by passing a function
// (as opposed to using trailing closure syntax)
func validateShape(event: Event) {
  guard let event = event as? RequestShapeValidation else { return }
  
  print("The proposed color for myObject is \(event.shape.color)")
  
  if !["red", "blue", "green"].contains(event.shape.color) {
    event.invalidReason = "Color is all wrong: \(event.shape.color)"
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

