# SwiftEmit

PubSub for Swift. Unifies and simplifies event handling for swift objects, 
NS KVO events, NSNotificationCenter events, etc.

Define some event payload types:
```
class ColorChange {
  color: String
}
```

Register handlers for those events:
```

// using trailing closure syntax:
myEmitter.on(ColorChange.self) { event in
  guard let payload = event.payload as? ValueChange else { return }
  print("The new color for myObject is \(payload.color)")
}

// or by passing a function: 
func colorChanged(event: Event) {
  guard let payload = event.payload as? ValueChange else { return }
  print("The new color for myObject is \(payload.color)")
}
myEmitter.on(ColorChange.self, run: colorChanged)

```

Emit events:
```
  emit(ColorChange(color: color))
```

To emit events, a class or struct must be an Emitter, which means it must be 
Hashable (and thus Equatable). 

Be very careful mapping handlers to structs. If a struct's attributes change, 
then in all likelihood its identity changes too, and thus which handlers 
that SwiftEmit associates with it (see StructEmitTests.swift in this project).

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

## Features/Comparison


* Pub-Sub pattern similar to nodejs Emitter, but...
* ...Emits objects (or structs) instead of string events (concept copied from 'Announcements' in smalltalk). Eg. see http://pharo.gemtalksystems.com/book/LanguageAndLibraries/announcements/
* Simple syntax to emit a payload, register/deregister event handlers
* Event contains: the payload, the context. The payload is the thing emitted, the context is a Dictionary with string keys and arbitrary values. Handlers can side-effect the context.

    ```
     func myHandler(event: Event) {
       guard let payload = event.payload as? SomePayload else { return }
       guard let sender = event.context["sender"] as? SomeClass else {return }
       ...do something with payload, eg:....
       if isInvalid(payload.something) { 
          event.context["invalid"] = "some reason" 
       }
     }
     myObject.on(SomePayload.self, run: myHandler)
    ```

* Any Hashable class event emitter

* Any Hashable struct can be event emitter, but be careful, if struct changes, it's handler mappings may change too (see StructEmitTests.swift)

* Instances of any struct or class or enums can be payloads.

* Adaptors for NS KVO, NotificationCenter, NSOperationQueue, where handlers take the same form as regular SwiftEmit events. (see examples below)

## Examples

### KVO Events:

(Example is for observing the ISO value of a camera on an iphone)

SwiftEmit:
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

compare to the standard Swift equivalent for example above:

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

Standard Swift equivalent for example above:

    let ctr = NSNotificationCenter.defaultCenter()
    ctr.addObserver(self,
      selector: "handleGuidedAccessChange",
      name: UIAccessibilityGuidedAccessStatusDidChangeNotification,
      object: nil)

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

Standard Swift equivalent for example above:

   ```swift
    let motionManager = CMMotionManager()
    let queue NSOperationQueue.currentQueue()
    motionManager.deviceMotionUpdateInterval = 1
    guard let queue = nsOpQueue else {
      return warn("WARNING: Could not start core motion observer, no op Q found")
    }
    motionManager.startDeviceMotionUpdatesToQueue(queue) { (deviceMotion, error) in
      self.handleDeviceMotionUpdate(deviceMotion, error)
      guard error == nil else {
        return warn("Process motion ns error: \(payload.error)")
      }
      guard let deviceMotion = deviceMotion else {
        return warn("Process motion event contains neither motion nor error")
      }
    }
    processMotion(deviceMotion)
   ```

### Your Own Class

(this example can be copy/pasted into an xcode playground)

```swift

//Your own event payload class or struct
struct AboutToChangeColor { }
struct ColorChanged {
  var color: String
}

// Make your class or struct an Emitter (Hashable), and have it emit events when
// one of it's variables changes
struct Cat: Emitter {
  var hashValue: Int { return name.hashValue } // Emitters must be Hashable
  var name: String = "Snowball"
  var color = "white" {
    willSet {
      emit(AboutToChangeColor())
    }
    didSet {
      emit(ColorChanged(color: color))
    }
  }
}

// Emitters are Hashable, and thus must be Equatable:
func ==(x: Cat, y: Cat) -> Bool {
  return x.hashValue == y.hashValue
}

// Ok, now lets get a cat to observe
var myCat = Cat()

// Have another object observe the events by passing a function handler...

func catAboutToChange(event: Event) {
  guard event.payload is AboutToChangeColor else { return }
  guard let cat = event.context["sender"] as? Cat else {return }
  print("\(cat.name) about to change color?!")
}

myCat.on(AboutToChangeColor.self, run: catAboutToChange)

//...or, have another object observe the events by using trailing closure  syntax
myCat.on(ColorChanged.self) { event in
  guard let payload = event.payload as? ColorChanged else { return }
  guard let cat = event.context["sender"] as? Cat else {return }
  print("\(cat.name) is now \(payload.color)?!! It's a miracle!")
}

myCat.color = "blue" // trigger AboutToChangeColor and ColorChanged handlers
```

