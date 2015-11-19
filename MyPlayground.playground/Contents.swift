//: Playground - noun: a place where people can play

import UIKit
import SwiftEmit

var str = "Hello, playground"
["hi", "there"].contains("hio")

class Cat {
  var color = "red"
}

struct Dog: Equatable {
  var color = "red"
}

func ==(d1: Dog, d2: Dog) -> Bool {
  return d1.color == d2.color
}

func emitEqual<T: AnyObject>(thing1: T, _ thing2: T) -> Bool {
  return thing1 === thing2
}

func emitEqual<T: Equatable>(thing1: T, _ thing2: T) -> Bool {
  return thing1 == thing2
}

func swiftEmitHashValue<T: AnyObject>(obj: T) -> Int {
  return ObjectIdentifier(obj).hashValue
}

func swiftEmitHashValue(d: Dog) -> Int {
  return d.color.hashValue
}

let cat1 = Cat()
let cat2 = Cat()
let dog1 = Dog()
let dog2 = Dog()
var dog3 = Dog()
dog3.color = "purple"

swiftEmitHashValue(cat1)
swiftEmitHashValue(cat2)
swiftEmitHashValue(dog3)
swiftEmitHashValue(dog2)

emitEqual(cat1, cat2)
emitEqual(cat1, cat1)
emitEqual(dog1, dog1)
emitEqual(dog1, dog2)
emitEqual(dog1, dog3)
emitEqual(dog2, dog3)
emitEqual(dog3, dog3)

cat1 === cat2
//ObjectIdentifier(cat1).hashValue

"ho"

