//
//  RaceDistanceTypeTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-28.
//

import Testing

@testable import MedalWall

struct RaceDistanceTypeTests {

  // MARK: - displayName
  @Test("In-person display name")
  func testInPersonDisplayName() {
    #expect(RaceDistanceType.inPerson.displayName == "In-person")
  }

  @Test("Virtual display name")
  func testVirtualDisplayName() {
    #expect(RaceDistanceType.virtual.displayName == "Virtual")
  }

  @Test("Wheelchair display name")
  func testWheelChairDisplayName() {
    #expect(RaceDistanceType.wheelChair.displayName == "Wheel Chair")
  }

  // MARK: - sortOrder
  @Test("In-person sorts before virtual and wheelchair")
  func testInPersonSortOrder() {
    #expect(RaceDistanceType.inPerson.sortOrder < RaceDistanceType.virtual.sortOrder)
    #expect(RaceDistanceType.inPerson.sortOrder < RaceDistanceType.wheelChair.sortOrder)
  }

  @Test("Virtual sorts before wheelchair")
  func testVirtualSortOrder() {
    #expect(RaceDistanceType.virtual.sortOrder < RaceDistanceType.wheelChair.sortOrder)
  }
}
