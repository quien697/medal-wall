//
//  RaceEventTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-28.
//

import Foundation
import Testing

@testable import MedalWall

struct RaceEventTests {

  // MARK: - Support
  /// Decodes a `RaceEvent` from a JSON object literal.
  private static func decode(_ json: String) throws -> RaceEvent {
    try JSONDecoder().decode(RaceEvent.self, from: Data(json.utf8))
  }

  /// Encodes a `RaceEvent` and reads it back as the plain dictionary a document holds.
  private static func encodedFields(_ event: RaceEvent) throws -> [String: Any] {
    let data = try JSONEncoder().encode(event)
    return try JSONSerialization.jsonObject(with: data) as? [String: Any] ?? [:]
  }

  // MARK: - displayLabel
  @Test("In-person label shows only category description")
  func testDisplayLabelInPerson() {
    let event = RaceEvent(category: .full, type: .inPerson)

    #expect(event.displayLabel == "Full")
  }

  @Test("Virtual label prefixes type name before category description")
  func testDisplayLabelVirtual() {
    let event = RaceEvent(category: .full, type: .virtual)

    #expect(event.displayLabel == "Virtual Full")
  }

  @Test("Wheelchair label prefixes type name before category description")
  func testDisplayLabelWheelChair() {
    let event = RaceEvent(category: .half, type: .wheelChair)

    #expect(event.displayLabel == "Wheel Chair Half")
  }

  // MARK: - Equality
  @Test("Two events with the same category and type are equal")
  func testEqualityMatch() {
    let lhs = RaceEvent(category: .full, type: .inPerson)
    let rhs = RaceEvent(category: .full, type: .inPerson)

    #expect(lhs == rhs)
  }

  @Test("Events with different types are not equal")
  func testEqualityDifferentType() {
    let lhs = RaceEvent(category: .full, type: .inPerson)
    let rhs = RaceEvent(category: .full, type: .virtual)

    #expect(lhs != rhs)
  }

  @Test("Events with different categories are not equal")
  func testEqualityDifferentCategory() {
    let lhs = RaceEvent(category: .full, type: .inPerson)
    let rhs = RaceEvent(category: .half, type: .inPerson)

    #expect(lhs != rhs)
  }

  @Test("The same number in another unit is a different event")
  func testEqualityDifferentUnit() {
    let tenKilometers = RaceEvent(category: .tenKM, type: .inPerson)
    let tenMiles = RaceEvent(
      category: RaceDistanceCategory(value: 10, unit: .miles),
      type: .inPerson
    )

    #expect(tenKilometers != tenMiles)
  }

  @Test("Equal events hash alike, so a set holds one of them")
  func testHashMatchesEquality() {
    let events: Set = [
      RaceEvent(category: RaceDistanceCategory(value: 10, unit: .miles), type: .inPerson),
      RaceEvent(category: RaceDistanceCategory(value: 10, unit: .miles), type: .inPerson)
    ]

    #expect(events.count == 1)
  }

  // MARK: - Comparable
  @Test("In-person sorts before virtual")
  func testSortTypeOrder() {
    let inPerson = RaceEvent(category: .full, type: .inPerson)
    let virtual = RaceEvent(category: .full, type: .virtual)

    #expect(inPerson < virtual)
  }

  @Test("Within same type, larger distance sorts first")
  func testSortDistanceOrder() {
    let full = RaceEvent(category: .full, type: .inPerson)
    let half = RaceEvent(category: .half, type: .inPerson)

    #expect(full < half)
  }

  @Test("A distance in miles sorts by its real length")
  func testSortRealLength() {
    let tenMiles = RaceEvent(
      category: RaceDistanceCategory(value: 10, unit: .miles),
      type: .inPerson
    )
    let sixteenKilometers = RaceEvent(
      category: RaceDistanceCategory(value: 16, unit: .kilometers),
      type: .inPerson
    )

    #expect(tenMiles < sixteenKilometers)
  }

  @Test("At an equal real length, kilometres sort before miles")
  func testSortEqualLengthKilometersFirst() {
    let tenMiles = RaceEvent(
      category: RaceDistanceCategory(value: 10, unit: .miles),
      type: .inPerson
    )
    let sameInKilometers = RaceEvent(
      category: RaceDistanceCategory(value: 10 * DistanceUnit.kilometersPerMile, unit: .kilometers),
      type: .inPerson
    )

    #expect(sameInKilometers < tenMiles)
    #expect(!(tenMiles < sameInKilometers))
  }

  @Test("Sorted array places in-person full first and virtual last")
  func testSortedArray() {
    let events = [
      RaceEvent(category: .half, type: .inPerson),
      RaceEvent(category: .full, type: .virtual),
      RaceEvent(category: .full, type: .inPerson)
    ].sorted()

    #expect(events[0] == RaceEvent(category: .full, type: .inPerson))
    #expect(events[1] == RaceEvent(category: .half, type: .inPerson))
    #expect(events[2] == RaceEvent(category: .full, type: .virtual))
  }

  // MARK: - Default
  @Test("Default event is full in-person")
  func testDefault() {
    #expect(RaceEvent.default == RaceEvent(category: .full, type: .inPerson))
  }

  // MARK: - Encoding
  @Test("Encoding writes the kind, the value, the unit and the type")
  func testEncodedFields() throws {
    let event = RaceEvent(
      category: RaceDistanceCategory(value: 10, unit: .miles),
      type: .virtual
    )
    let fields = try Self.encodedFields(event)

    #expect(fields["kind"] as? String == "distance")
    #expect(fields["value"] as? Double == 10)
    #expect(fields["unit"] as? String == "miles")
    #expect(fields["type"] as? String == "virtual")
    #expect(fields.count == 4)
  }

  @Test("An event survives an encode/decode round-trip")
  func testCodableRoundTrip() throws {
    let original = RaceEvent(
      category: RaceDistanceCategory(value: 26.2, unit: .miles),
      type: .virtual
    )
    let data = try JSONEncoder().encode(original)
    let decoded = try JSONDecoder().decode(RaceEvent.self, from: data)

    #expect(decoded == original)
  }

  // MARK: - Decoding
  @Test("A stored standard distance decodes as that standard")
  func testDecodeStandard() throws {
    let event = try Self.decode(
      #"{"kind": "distance", "value": 42.195, "unit": "kilometers", "type": "inPerson"}"#
    )

    #expect(event == RaceEvent(category: .full, type: .inPerson))
  }

  @Test("A near-standard distance decodes as itself, not the standard")
  func testDecodeNearStandard() throws {
    let event = try Self.decode(
      #"{"kind": "distance", "value": 42.2, "unit": "kilometers", "type": "inPerson"}"#
    )

    #expect(event.category == RaceDistanceCategory(value: 42.2, unit: .kilometers))
  }

  @Test("An event with no kind does not decode")
  func testDecodeMissingKind() {
    #expect(throws: (any Error).self) {
      try Self.decode(#"{"value": 42.195, "unit": "kilometers", "type": "inPerson"}"#)
    }
  }

  @Test("An event of another kind does not decode")
  func testDecodeOtherKind() {
    #expect(throws: (any Error).self) {
      try Self.decode(
        #"{"kind": "time", "value": 24, "unit": "kilometers", "type": "inPerson"}"#
      )
    }
  }

  @Test("An event with no unit does not decode")
  func testDecodeMissingUnit() {
    #expect(throws: (any Error).self) {
      try Self.decode(#"{"kind": "distance", "value": 42.195, "type": "inPerson"}"#)
    }
  }

  @Test("A unit spelled other than kilometers or miles does not decode")
  func testDecodeUnknownUnit() {
    #expect(throws: (any Error).self) {
      try Self.decode(#"{"kind": "distance", "value": 10, "unit": "mi", "type": "inPerson"}"#)
    }
  }

  @Test("Unknown type string falls back to inPerson on decode")
  func testDecodeUnknownTypeFallback() throws {
    let event = try Self.decode(
      #"{"kind": "distance", "value": 42.195, "unit": "kilometers", "type": "unknown"}"#
    )

    #expect(event.type == .inPerson)
    #expect(event.category == .full)
  }
}
