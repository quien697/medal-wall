//
//  PhotoChecksTests.swift
//  MedalWall
//
//  Created by Quien on 2026-11-20.
//

import Testing

@testable import MedalWall

struct PhotoChecksTests {

  @Test("no photo is being checked until a check starts")
  func testIdleAtFirst() {
    #expect(!PhotoChecks().isChecking)
  }

  @Test("overlapping checks keep a photo being checked until the last one ends")
  func testOverlappingChecks() {
    var checks = PhotoChecks()
    checks.changed(isChecking: true)
    checks.changed(isChecking: true)
    checks.changed(isChecking: false)

    #expect(checks.isChecking)

    checks.changed(isChecking: false)

    #expect(!checks.isChecking)
  }

  @Test("a check that ends without starting is ignored, so a later check still counts")
  func testStrayEndIgnored() {
    var checks = PhotoChecks()
    checks.changed(isChecking: false)
    checks.changed(isChecking: true)

    #expect(checks.isChecking)
  }
}
