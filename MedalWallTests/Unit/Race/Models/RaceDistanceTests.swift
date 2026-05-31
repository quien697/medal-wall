//
//  RaceDistanceTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-28.
//

import Foundation
import Testing

@testable import MedalWall

struct RaceDistanceTests {

  // MARK: - displayLabel
  @Test("In-person label shows only category description")
  func testDisplayLabelInPerson() {
    let distance = RaceDistance(category: .full, type: .inPerson)

    #expect(distance.displayLabel == "42km")
  }

  @Test("Virtual label prefixes type name before category description")
  func testDisplayLabelVirtual() {
    let distance = RaceDistance(category: .full, type: .virtual)

    #expect(distance.displayLabel == "Virtual 42km")
  }

  @Test("Wheelchair label prefixes type name before category description")
  func testDisplayLabelWheelChair() {
    let distance = RaceDistance(category: .half, type: .wheelChair)

    #expect(distance.displayLabel == "Wheel Chair 21km")
  }

  // MARK: - Equality
  @Test("Two distances with the same category and type are equal")
  func testEqualityMatch() {
    let lhs = RaceDistance(category: .full, type: .inPerson)
    let rhs = RaceDistance(category: .full, type: .inPerson)

    #expect(lhs == rhs)
  }

  @Test("Distances with different types are not equal")
  func testEqualityDifferentType() {
    let lhs = RaceDistance(category: .full, type: .inPerson)
    let rhs = RaceDistance(category: .full, type: .virtual)

    #expect(lhs != rhs)
  }

  @Test("Distances with different categories are not equal")
  func testEqualityDifferentCategory() {
    let lhs = RaceDistance(category: .full, type: .inPerson)
    let rhs = RaceDistance(category: .half, type: .inPerson)

    #expect(lhs != rhs)
  }

  @Test("Two custom distances with the same value and type are equal")
  func testEqualityCustomMatch() {
    let lhs = RaceDistance(category: .custom(33.5), type: .inPerson)
    let rhs = RaceDistance(category: .custom(33.5), type: .inPerson)

    #expect(lhs == rhs)
  }

  @Test("Two custom distances with different values are not equal")
  func testEqualityCustomDifferentValue() {
    let lhs = RaceDistance(category: .custom(33.5), type: .inPerson)
    let rhs = RaceDistance(category: .custom(33.4), type: .inPerson)

    #expect(lhs != rhs)
  }

  // MARK: - Comparable
  @Test("In-person sorts before virtual")
  func testSortTypeOrder() {
    let inPerson = RaceDistance(category: .full, type: .inPerson)
    let virtual = RaceDistance(category: .full, type: .virtual)

    #expect(inPerson < virtual)
  }

  @Test("Within same type, larger distance sorts first")
  func testSortDistanceOrder() {
    let full = RaceDistance(category: .full, type: .inPerson)
    let half = RaceDistance(category: .half, type: .inPerson)

    #expect(full < half)
  }

  @Test("Sorted array places in-person full first and virtual last")
  func testSortedArray() {
    let distances = [
      RaceDistance(category: .half, type: .inPerson),
      RaceDistance(category: .full, type: .virtual),
      RaceDistance(category: .full, type: .inPerson)
    ].sorted()

    #expect(distances[0] == RaceDistance(category: .full, type: .inPerson))
    #expect(distances[1] == RaceDistance(category: .half, type: .inPerson))
    #expect(distances[2] == RaceDistance(category: .full, type: .virtual))
  }

  // MARK: - Default
  @Test("Default distance is full in-person")
  func testDefault() {
    #expect(RaceDistance.default == RaceDistance(category: .full, type: .inPerson))
  }

  // MARK: - Codable
  @Test("RaceDistance survives a JSON encode/decode round-trip")
  func testCodableRoundTrip() throws {
    let original = RaceDistance(category: .half, type: .virtual)
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(RaceDistance.self, from: data)

    #expect(decoded == original)
  }

  @Test("Custom distance value is preserved through Codable round-trip")
  func testCodableRoundTripCustom() throws {
    let original = RaceDistance(category: .custom(33.5), type: .inPerson)
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(RaceDistance.self, from: data)

    #expect(decoded == original)
  }

  @Test("Unknown type string in JSON falls back to inPerson on decode")
  func testCodableUnknownTypeFallback() throws {
    let json = #"{"value": 42.195, "type": "unknown"}"#
    let data = Data(json.utf8)
    let decoded = try JSONDecoder().decode(RaceDistance.self, from: data)

    #expect(decoded.type == .inPerson)
    #expect(decoded.category == .full)
  }
}
