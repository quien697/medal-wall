//
//  MedalDistanceFilterTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-07.
//

import Foundation
import Testing

@testable import MedalWall

struct MedalDistanceFilterTests {

  // MARK: - Identity
  @Test("All and a category carry distinct ids")
  func testAllAndCategoryHaveDistinctIDs() {
    #expect(MedalDistanceFilter.all.id != MedalDistanceFilter.category(.full).id)
  }

  @Test("Two categories at different distances carry distinct ids")
  func testDifferentCategoriesHaveDistinctIDs() {
    #expect(MedalDistanceFilter.category(.full).id != MedalDistanceFilter.category(.half).id)
  }

  @Test("10K and 10 mi carry distinct ids")
  func testSameNumberInDifferentUnitsHasDistinctIDs() {
    #expect(
      MedalDistanceFilter.category(.tenKM).id != MedalDistanceFilter.category(Self.tenMiles).id)
  }

  private static let tenMiles = RaceDistanceCategory(value: 10, unit: .miles)

  // MARK: - Equality
  @Test("Two all cases are equal")
  func testAllEqualsAll() {
    #expect(MedalDistanceFilter.all == MedalDistanceFilter.all)
  }

  @Test("All never equals a category")
  func testAllNeverEqualsCategory() {
    #expect(MedalDistanceFilter.all != MedalDistanceFilter.category(.full))
  }

  @Test("Two categories at the same distance are equal")
  func testSameCategoryIsEqual() {
    #expect(MedalDistanceFilter.category(.half) == MedalDistanceFilter.category(.half))
  }

  @Test("Two categories at different distances are not equal")
  func testDifferentCategoryIsNotEqual() {
    #expect(MedalDistanceFilter.category(.full) != MedalDistanceFilter.category(.tenKM))
  }

  @Test("A custom distance of exactly a standard equals that standard")
  func testCustomDistanceEqualsMatchingPreset() {
    #expect(
      MedalDistanceFilter.category(RaceDistanceCategory(value: 42.195, unit: .kilometers))
        == MedalDistanceFilter.category(.full))
  }

  @Test("A custom distance that matches no preset stays distinct")
  func testUnmatchedCustomDistanceStaysDistinct() {
    #expect(
      MedalDistanceFilter.category(RaceDistanceCategory(value: 30, unit: .kilometers))
        != MedalDistanceFilter.category(.full))
  }

  @Test("A near-standard distance does not equal the standard")
  func testNearStandardDistanceIsNotTheStandard() {
    #expect(
      MedalDistanceFilter.category(RaceDistanceCategory(value: 42.2, unit: .kilometers))
        != MedalDistanceFilter.category(.full))
  }

  @Test("10K and 10 mi are not equal")
  func testSameNumberInDifferentUnitsIsNotEqual() {
    #expect(MedalDistanceFilter.category(.tenKM) != MedalDistanceFilter.category(Self.tenMiles))
  }

  // MARK: - Hashing
  @Test("A custom distance of exactly a standard is one entry with it in a set")
  func testCustomDistanceCollapsesInSet() {
    let filters: Set<MedalDistanceFilter> = [
      .category(.full),
      .category(RaceDistanceCategory(value: 42.195, unit: .kilometers))
    ]

    #expect(filters.count == 1)
  }

  @Test("Distinct filters all survive in a set")
  func testDistinctFiltersSurviveInSet() {
    let filters: Set<MedalDistanceFilter> = [
      .all,
      .category(.full),
      .category(.half),
      .category(RaceDistanceCategory(value: 30, unit: .kilometers)),
      .category(.tenKM),
      .category(Self.tenMiles)
    ]

    #expect(filters.count == 6)
  }
}
