//
//  NSAdaptorTests.swift
//  SwiftEmit
//
//  Created by Steven Swerling on 11/19/15.
//  Copyright © 2015 Steven Swerling. All rights reserved.
//

import XCTest
@testable import SwiftEmit

class NSAdaptorTests: XCTestCase {
  
  func testCoreMotion() {
    // uh oh. How? 
    // Maybe just send mock events through NSOperationQ and call it a day?
  }
  
  func testNotificationCenter() {
    var proof:String? = nil
    NotificationCenter.default.swiftEmit("notifyme") { event in
      proof = "Notified"
    }
    XCTAssert(proof == nil,
      "should NOT have gotten NotificationCenter event, haven't started observer yet")
    
    // In following calls, doing multiple stopAll and startAll calls in a row
    // because in SwiftEmit, calls to addObserver and removeObserver are idempotent
    SwiftEmitNS.startAll()
    SwiftEmitNS.startAll()
    SwiftEmitNS.startAll()
    NotificationCenter.default.post(name: Notification.Name(rawValue: "notifyme"), object: nil)
    XCTAssert(proof == "Notified",
      "should have gotten NotificationCenter event, handler should set proof to 'Notified'")
    
    // make sure stop is also idempotent
    SwiftEmitNS.stopAll()
    SwiftEmitNS.stopAll()
    SwiftEmitNS.stopAll()
    proof = "blah"
    NotificationCenter.default.post(name: Notification.Name(rawValue: "notifyme"), object: nil)
    XCTAssert(proof == "blah",
      "should NOT have gotten NotificationCenter event, stopped observer")
    
  }
  
  class NSDevice: NSObject {
    dynamic var floatVar: Float = 200
    dynamic var boolVar: Bool = true
    
    dynamic var intVar: Int = -1
    dynamic var uintVar: UInt = 1
    
    dynamic var int8Var: Int8 = -1
    dynamic var uint8Var: UInt8 = 1
    
    dynamic var int16Var: Int16 = 1
    dynamic var uint16Var: UInt16 = 1
    
    dynamic var int64Var: Int64 = 1
    dynamic var uint64Var: UInt64 = 1
  }
  
  func testKVOUInts() {
    let device = NSDevice()
    
    var proof:Int? = nil
    
    // INT
    device.swiftEmitInt(Int(), keyPath: "intVar") { event in
      proof = (event as? Events.KVO)?.newValue as? Int
    }
    SwiftEmitNS.startAll()
    device.intVar = -100
    XCTAssert(proof == -100,
      "should have gotten KVO event setting fake device intVar to -100")
    
    // UINT
    device.swiftEmitUInt(UInt(), keyPath: "uintVar") { event in
      proof = (event as? Events.KVO)?.newValue as? Int
    }
    SwiftEmitNS.startAll()
    device.intVar = 100
    XCTAssert(proof == 100,
      "should have gotten KVO event setting fake device uintVar to 100")
    
    // INT8
    device.swiftEmitInt(Int8(), keyPath: "int8Var") { event in
      proof = (event as? Events.KVO)?.newValue as? Int
    }
    SwiftEmitNS.startAll()
    device.int8Var = -8
    XCTAssert(proof == -8,
      "should have gotten KVO event setting fake device int8Var to -8")

    // UINT8
    device.swiftEmitUInt(UInt8(), keyPath: "uint8Var") { event in
      proof = (event as? Events.KVO)?.newValue as? Int
    }
    SwiftEmitNS.startAll()
    device.uint8Var = 8
    XCTAssert(proof == 8,
      "should have gotten KVO event setting fake device uint8Var to 8")
    
    // INT16
    device.swiftEmitInt(Int16(), keyPath: "int16Var") { event in
      proof = (event as? Events.KVO)?.newValue as? Int
    }
    SwiftEmitNS.startAll()
    device.int16Var = -16
    XCTAssert(proof == -16,
      "should have gotten KVO event setting fake device int16Var to -16")
    
    // UINT16
    device.swiftEmitUInt(UInt16(), keyPath: "uint16Var") { event in
      proof = (event as? Events.KVO)?.newValue as? Int
    }
    SwiftEmitNS.startAll()
    device.uint16Var = 2
    XCTAssert(proof == 2,
      "should have gotten KVO event setting fake device uint16Var to -2")
  }
  
  func testKVOBool() {
    let device = NSDevice()
    device.boolVar = false
    var proof:Bool? = nil
    device.swiftEmitBool("boolVar") { event in
      guard let event = event as? Events.KVO else { return }
      proof = event.newValue as? Bool // tests below look for this
    }
    SwiftEmitNS.startAll()
    device.boolVar = true
    XCTAssert(proof == true,
      "should have gotten KVO event setting fake device boolVar to true")
  }
  
  func testKVOStartStop() {
    let device = NSDevice()
    device.floatVar = 200
    var proof:Float? = nil
    device.swiftEmitFloat("floatVar") { event in
      guard let event = event as? Events.KVO else { return }
      proof = event.newValue as? Float // tests below look for this
    }
    
    device.floatVar = 300
    XCTAssert(proof == nil,
      "should NOT have gotten KVO event yet, did not yet SwiftEmitNS.startAll()")
    
    SwiftEmitNS.startAll()
    device.floatVar = 400
    XCTAssert(proof == 400,
      "should have gotten KVO event setting fake camera floatVar to 400")
    
    // In following calls, doing multiple stopAll and startAll calls in a row because in SwiftEmit, calls to KVO addObserver and removeObserver are idempotent
    
    SwiftEmitNS.startAll()
    SwiftEmitNS.startAll()
    SwiftEmitNS.startAll()
    device.floatVar = 400
    XCTAssert(proof == 400,
      "should have gotten KVO event setting fake camera floatVar to 400")
    
    SwiftEmitNS.stopAll()
    SwiftEmitNS.stopAll()
    SwiftEmitNS.stopAll()
    device.floatVar = 500
    XCTAssert(proof == 400,
      "should NOT have gotten KVO event, did SwiftEmitNS.stopAll()")
    
    SwiftEmitNS.startAll()
    device.floatVar = 700
    XCTAssert(proof == 700,
      "should have gotten KVO event setting fake camera floatVar to 700")
    
  }
  

}
