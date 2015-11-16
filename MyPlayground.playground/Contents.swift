//: Playground - noun: a place where people can play

import UIKit
import SwiftEmit

var str = "Hello, playground"
var event2 = ValueChangeEvent(oldValue: 1, newValue: 2)
print("e2: \(event2.self)")

/*
print(String(event1.dynamicType))
print(String(event1.dynamicType))
"\(event1.dynamicType)"
"\(event1.dynamicType)".hashValue
"event1.self"
 _stdlib_getDemangledTypeName(event1).hashValue

struct EventClassKey: Hashable {
  private let underlying: Event
  init<T: Event>(_ e: T) {
    underlying = e
  }
  
  func toString() -> String {
    return "\(underlying)"
  }
  //var hashValue: Int { return hashValueFunc() }
  var hashValue: Int { return toString().hashValue }
  func eql(y: EventClassKey) -> Bool {
    return toString() == y.toString()
  }
}

func ==(x: EventClassKey, y: EventClassKey) -> Bool {
  return x.eql(y)
}


var dict1: [EventClassKey: String] = [EventClassKey(event1): "e1", EventClassKey(event2): "e2"]

print(dict1[EventClassKey(event1)])
print(dict1[EventClassKey(event2)])

struct AnyKey: Hashable {
  private let underlying: [Any]
  private let hashValueFunc: () -> Int
  private let equalityFunc: (Any) -> Bool
  
  init<T: Hashable>(_ key: T) {
    underlying = [key]
    // Capture the key's hashability and equatability using closures.
    // The Key shares the hash of the underlying value.
    hashValueFunc = { key.hashValue }
    
    // The Key is equal to a Key of the same underlying type,
    // whose underlying value is "==" to ours.
    equalityFunc = {
      if let other = $0 as? T {
        return key == other
      }
      return false
    }
  }
  
  var hashValue: Int { return hashValueFunc() }
}

func ==(x: AnyKey, y: AnyKey) -> Bool {
  return x.equalityFunc(y.underlying[0])
}

var dict: [AnyKey: Int] = [AnyKey("foo"): 1, AnyKey(22): 2]

print(dict[AnyKey("foo")])
print(dict[AnyKey(22)])
*/