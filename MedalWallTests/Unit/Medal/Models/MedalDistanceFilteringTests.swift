//
//  MedalDistanceFilteringTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-07.
//

import Foundation
import Testing

@testable import MedalWall

struct MedalDistanceFilteringTests {

  private func makeMedal(
    id: String = UUID().uuidString,
    category: RaceDistanceCategory,
    type: RaceDistanceType = .inPerson
  ) -> Medal {
    Medal(
      id: id,
      name: "Test",
      date: .now,
      bibNumber: "1",
      place: Place(countryCode: "CA", city: "Vancouver"),
      distance: RaceDistance(category: category, type: type),
      userID: "user1"
    )
  }

  // MARK: - distanceCategoriesOwned
  @Test("distanceCategoriesOwned is empty for an empty collection")
  func testCategoriesOwnedEmpty() {
    let medals: [Medal] = []

    #expect(medals.distanceCategoriesOwned.isEmpty)
  }

  @Test("distanceCategoriesOwned returns only categories the collection contains")
  func testCategoriesOwnedOnlyPresent() {
    let medals = [
      makeMedal(category: .half),
      makeMedal(category: .tenKM)
    ]

    let owned = medals.distanceCategoriesOwned.map(\.value)

    #expect(owned == [RaceDistanceCategory.half.value, RaceDistanceCategory.tenKM.value])
  }

  @Test("distanceCategoriesOwned orders categories longest first")
  func testCategoriesOwnedOrderedLongestFirst() {
    let medals = [
      makeMedal(category: .fiveKM),
      makeMedal(category: .full),
      makeMedal(category: .half)
    ]

    let owned = medals.distanceCategoriesOwned.map(\.value)

    #expect(
      owned == [
        RaceDistanceCategory.full.value,
        RaceDistanceCategory.half.value,
        RaceDistanceCategory.fiveKM.value
      ]
    )
  }

  @Test("distanceCategoriesOwned lists a shared category once")
  func testCategoriesOwnedDeduplicates() {
    let medals = [
      makeMedal(category: .full),
      makeMedal(category: .full),
      makeMedal(category: .full)
    ]

    #expect(medals.distanceCategoriesOwned.count == 1)
  }

  @Test("distanceCategoriesOwned does not split a category across race types")
  func testCategoriesOwnedIgnoresRaceType() {
    let medals = [
      makeMedal(category: .full, type: .inPerson),
      makeMedal(category: .full, type: .virtual)
    ]

    #expect(medals.distanceCategoriesOwned.count == 1)
  }

  @Test("distanceCategoriesOwned surfaces a custom distance as its own category")
  func testCategoriesOwnedIncludesCustom() {
    let medals = [
      makeMedal(category: .full),
      makeMedal(category: .custom(30)),
      makeMedal(category: .half)
    ]

    let owned = medals.distanceCategoriesOwned.map(\.value)

    #expect(owned == [42.195, 30, 21.0975])
  }

  @Test("distanceCategoriesOwned collapses a custom distance onto the preset it measures")
  func testCategoriesOwnedCollapsesCustomOntoPreset() {
    let medals = [
      makeMedal(category: .full),
      makeMedal(category: .custom(42.195))
    ]

    #expect(medals.distanceCategoriesOwned.count == 1)
  }

  /// A marathon entered as 26.2 miles arrives as 42.16481 km — close to but not exactly
  /// 42.195, so it lands as `.custom(42.16481)` rather than `.custom(42.195)`. The
  /// tolerance that collapses it onto `.full` must run *before* the Set dedup, otherwise
  /// the chip surfaces two `.full` entries side by side and `personalBests` emits two
  /// records that share an `id`, breaking the carousel's `ForEach`.
  @Test(
    "distanceCategoriesOwned collapses a near-tolerance custom distance onto the preset it measures"
  )
  func testCategoriesOwnedCollapsesNearToleranceCustomOntoPreset() {
    let medals = [
      makeMedal(category: .full),
      makeMedal(category: .custom(42.16481))
    ]

    #expect(medals.distanceCategoriesOwned.count == 1)
    #expect(medals.distanceCategoriesOwned.first == .full)
  }

  /// CLAUDE.md `## Patterns`: "Guard numeric values against out-of-range inputs."
  /// A corrupt Firestore write can deliver a non-finite distance; sorting a
  /// `Set<Double>` that contains NaN or Inf traps, so non-finite values must be
  /// dropped before the sort.
  @Test("distanceCategoriesOwned drops non-finite values rather than trap")
  func testCategoriesOwnedDropsNonFiniteValues() {
    let medals = [
      makeMedal(category: .full),
      makeMedal(category: .custom(Double.nan)),
      makeMedal(category: .custom(Double.infinity))
    ]

    let owned = medals.distanceCategoriesOwned.map(\.value)

    #expect(owned == [RaceDistanceCategory.full.value])
  }

  // MARK: - count(for:)
  @Test("count for all returns the whole collection count")
  func testCountForAll() {
    let medals = [
      makeMedal(category: .full),
      makeMedal(category: .half)
    ]

    #expect(medals.count(for: .all) == 2)
  }

  @Test("count for a category returns only that category")
  func testCountForCategory() {
    let medals = [
      makeMedal(category: .full),
      makeMedal(category: .full),
      makeMedal(category: .full),
      makeMedal(category: .full),
      makeMedal(category: .full),
      makeMedal(category: .half),
      makeMedal(category: .half),
      makeMedal(category: .half),
      makeMedal(category: .half)
    ]

    #expect(medals.count(for: .all) == 9)
    #expect(medals.count(for: .category(.full)) == 5)
    #expect(medals.count(for: .category(.half)) == 4)
  }

  @Test("count for a category the collection does not contain is zero")
  func testCountForAbsentCategory() {
    let medals = [makeMedal(category: .full)]

    #expect(medals.count(for: .category(.fiveKM)) == 0)
  }

  // MARK: - filtered(by:)
  @Test("filtered by all returns every medal")
  func testFilteredByAll() {
    let medals = [
      makeMedal(category: .full),
      makeMedal(category: .half)
    ]

    #expect(medals.filtered(by: .all).count == 2)
  }

  @Test("filtered by a category returns only matching medals")
  func testFilteredByCategory() {
    let medals = [
      makeMedal(id: "full", category: .full),
      makeMedal(id: "half", category: .half)
    ]

    #expect(medals.filtered(by: .category(.half)).map(\.id) == ["half"])
  }

  @Test("filtered by a category keeps every race type at that distance")
  func testFilteredByCategoryKeepsAllTypes() {
    let medals = [
      makeMedal(category: .full, type: .inPerson),
      makeMedal(category: .full, type: .virtual),
      makeMedal(category: .half)
    ]

    #expect(medals.filtered(by: .category(.full)).count == 2)
  }

  @Test("filtered by a custom distance matches the preset it measures")
  func testFilteredByCustomMatchesPreset() {
    let medals = [
      makeMedal(category: .custom(42.195)),
      makeMedal(category: .half)
    ]

    #expect(medals.filtered(by: .category(.full)).count == 1)
  }

  /// A marathon entered as 26.2 miles rounds to 42.16481 km, just inside the 0.05 km
  /// window `RaceDistanceCategory(value:)` collapses onto `.full`. `filtered(by:)` must
  /// agree with that normalization — otherwise the chip surfaces `.full` but selecting
  /// it excludes the medal that the personal-bests card lists under `.full`.
  @Test("filtered by a preset matches a custom distance within the preset's tolerance")
  func testFilteredByPresetMatchesCustomWithinTolerance() {
    let medals = [
      makeMedal(category: .custom(42.16481)),
      makeMedal(category: .half)
    ]

    #expect(medals.filtered(by: .category(.full)).count == 1)
  }

  /// The screen's central invariant: options are derived from the collection, so
  /// selecting any offered option can never empty the list.
  @Test("Every derived category selects at least one medal")
  func testEveryDerivedOptionSelectsSomething() {
    let medals = [
      makeMedal(category: .full),
      makeMedal(category: .half),
      makeMedal(category: .custom(30)),
      makeMedal(category: .fiveKM)
    ]

    for category in medals.distanceCategoriesOwned {
      #expect(medals.count(for: .category(category)) >= 1)
    }
  }
}
