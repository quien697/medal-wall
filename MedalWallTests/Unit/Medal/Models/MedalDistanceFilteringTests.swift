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
      event: RaceEvent(category: category, type: type),
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
      makeMedal(category: RaceDistanceCategory(value: 30, unit: .kilometers)),
      makeMedal(category: .half)
    ]

    let owned = medals.distanceCategoriesOwned.map(\.value)

    #expect(owned == [42.195, 30, 21.0975])
  }

  @Test("distanceCategoriesOwned counts a custom distance of exactly a standard as that standard")
  func testCategoriesOwnedTreatsExactStandardValueAsStandard() {
    let medals = [
      makeMedal(category: .full),
      makeMedal(category: RaceDistanceCategory(value: 42.195, unit: .kilometers))
    ]

    #expect(medals.distanceCategoriesOwned == [.full])
  }

  @Test("distanceCategoriesOwned keeps a near-standard distance as its own category, longer first")
  func testCategoriesOwnedKeepsNearStandardDistanceSeparate() {
    let medals = [
      makeMedal(category: .full),
      makeMedal(category: Self.fortyTwoPointTwoKilometers)
    ]

    #expect(medals.distanceCategoriesOwned == [Self.fortyTwoPointTwoKilometers, .full])
  }

  @Test("distanceCategoriesOwned keeps 10K and 10 mi apart, 10 mi first")
  func testCategoriesOwnedKeepsUnitsApart() {
    let medals = [
      makeMedal(category: .tenKM),
      makeMedal(category: Self.tenMiles)
    ]

    #expect(medals.distanceCategoriesOwned == [Self.tenMiles, .tenKM])
  }

  @Test("distanceCategoriesOwned lists kilometres first when two units measure the same length")
  func testCategoriesOwnedOrdersKilometersFirstAtEqualLength() {
    let sameLengthInKilometers = RaceDistanceCategory(
      value: 10 * DistanceUnit.kilometersPerMile, unit: .kilometers)
    let medals = [
      makeMedal(category: Self.tenMiles),
      makeMedal(category: sameLengthInKilometers)
    ]

    #expect(medals.distanceCategoriesOwned == [sameLengthInKilometers, Self.tenMiles])
  }

  private static let tenMiles = RaceDistanceCategory(value: 10, unit: .miles)
  private static let fortyTwoPointTwoKilometers = RaceDistanceCategory(
    value: 42.2, unit: .kilometers)

  /// CLAUDE.md `## Patterns`: "Guard numeric values against out-of-range inputs."
  /// A corrupt Firestore write can deliver a non-finite distance; sorting a
  /// `Set<Double>` that contains NaN or Inf traps, so non-finite values must be
  /// dropped before the sort.
  @Test("distanceCategoriesOwned drops non-finite values rather than trap")
  func testCategoriesOwnedDropsNonFiniteValues() {
    let medals = [
      makeMedal(category: .full),
      makeMedal(category: RaceDistanceCategory(value: Double.nan, unit: .kilometers)),
      makeMedal(category: RaceDistanceCategory(value: Double.infinity, unit: .kilometers))
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

  @Test("filtered by a standard matches a custom distance of exactly that standard")
  func testFilteredByStandardMatchesExactCustomValue() {
    let medals = [
      makeMedal(category: RaceDistanceCategory(value: 42.195, unit: .kilometers)),
      makeMedal(category: .half)
    ]

    #expect(medals.filtered(by: .category(.full)).count == 1)
  }

  @Test("filtered by a standard leaves out a near-standard distance, and the reverse")
  func testFilteredByStandardExcludesNearStandardDistance() {
    let medals = [
      makeMedal(id: "full", category: .full),
      makeMedal(id: "42.2", category: Self.fortyTwoPointTwoKilometers)
    ]

    #expect(medals.filtered(by: .category(.full)).map(\.id) == ["full"])
    #expect(medals.filtered(by: .category(Self.fortyTwoPointTwoKilometers)).map(\.id) == ["42.2"])
  }

  @Test("filtered by 10 mi leaves out a 10K, and the reverse")
  func testFilteredByUnitKeepsUnitsApart() {
    let medals = [
      makeMedal(id: "10K", category: .tenKM),
      makeMedal(id: "10 mi", category: Self.tenMiles)
    ]

    #expect(medals.filtered(by: .category(Self.tenMiles)).map(\.id) == ["10 mi"])
    #expect(medals.filtered(by: .category(.tenKM)).map(\.id) == ["10K"])
  }

  /// The screen's central invariant: options are derived from the collection, so
  /// selecting any offered option can never empty the list.
  @Test("Every derived category selects at least one medal")
  func testEveryDerivedOptionSelectsSomething() {
    let medals = [
      makeMedal(category: .full),
      makeMedal(category: .half),
      makeMedal(category: RaceDistanceCategory(value: 30, unit: .kilometers)),
      makeMedal(category: .fiveKM),
      makeMedal(category: Self.tenMiles),
      makeMedal(category: Self.fortyTwoPointTwoKilometers)
    ]

    for category in medals.distanceCategoriesOwned {
      #expect(medals.count(for: .category(category)) >= 1)
    }
  }
}
