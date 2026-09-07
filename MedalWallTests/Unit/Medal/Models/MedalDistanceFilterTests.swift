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

  /// A custom distance that happens to measure a preset must not split into a second
  /// bucket — `RaceDistance` already defines identity by `category.value` for this reason.
  @Test("A custom distance equals the preset it measures")
  func testCustomDistanceEqualsMatchingPreset() {
    #expect(MedalDistanceFilter.category(.custom(42.195)) == MedalDistanceFilter.category(.full))
  }

  @Test("A custom distance that matches no preset stays distinct")
  func testUnmatchedCustomDistanceStaysDistinct() {
    #expect(MedalDistanceFilter.category(.custom(30)) != MedalDistanceFilter.category(.full))
  }

  // MARK: - Hashing
  @Test("A custom distance collapses onto the preset it measures in a set")
  func testCustomDistanceCollapsesInSet() {
    let filters: Set<MedalDistanceFilter> = [
      .category(.full),
      .category(.custom(42.195))
    ]

    #expect(filters.count == 1)
  }

  @Test("Distinct filters all survive in a set")
  func testDistinctFiltersSurviveInSet() {
    let filters: Set<MedalDistanceFilter> = [
      .all,
      .category(.full),
      .category(.half),
      .category(.custom(30))
    ]

    #expect(filters.count == 4)
  }
}
