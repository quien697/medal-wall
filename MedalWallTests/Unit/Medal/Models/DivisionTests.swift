//
//  DivisionTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-29.
//

import Testing

@testable import MedalWall

struct DivisionTests {

  // MARK: - rawValue
  @Test("rawValue combines gender and age group raw values with a space")
  func testRawValue() {
    let division = Division(gender: .male, ageGroup: .from30to34)

    #expect(division.rawValue == "male from30to34")
  }

  // MARK: - displayName
  @Test("displayName combines gender short name and age group display name")
  func testDisplayName() {
    let division = Division(gender: .male, ageGroup: .from30to34)

    #expect(division.displayName == "M 30–34")
  }

  // MARK: - init?(rawValue:)
  @Test("init(rawValue:) reconstructs gender and age group from a valid raw value")
  func testInitFromValidRawValue() {
    let division = Division(rawValue: "male from30to34")

    #expect(division?.gender == .male)
    #expect(division?.ageGroup == .from30to34)
  }

  @Test("init(rawValue:) round-trips through rawValue to produce the same Division")
  func testInitFromRawValueRoundTrip() {
    let original = Division(gender: .male, ageGroup: .from30to34)
    let reconstructed = Division(rawValue: original.rawValue)

    #expect(reconstructed?.gender == original.gender)
    #expect(reconstructed?.ageGroup == original.ageGroup)
  }

  @Test("init(rawValue:) returns nil when gender component is not a valid Gender")
  func testInitFromRawValueInvalidGender() {
    #expect(Division(rawValue: "unknown from30to34") == nil)
  }

  @Test("init(rawValue:) returns nil when age group component is not a valid AgeGroup")
  func testInitFromRawValueInvalidAgeGroup() {
    #expect(Division(rawValue: "male unknownGroup") == nil)
  }

  @Test("init(rawValue:) returns nil when the raw value contains no space")
  func testInitFromRawValueNoSpace() {
    #expect(Division(rawValue: "malefrom30to34") == nil)
  }

  @Test("init(rawValue:) returns nil for an empty string")
  func testInitFromRawValueEmptyString() {
    #expect(Division(rawValue: "") == nil)
  }

  @Test("Female with 10-year age group has correct rawValue and displayName")
  func testInitFemaleAgeGroup() {
    let division = Division(gender: .female, ageGroup: .from60to69)

    #expect(division.rawValue == "female from60to69")
    #expect(division.displayName == "F 60–69")
  }
}
