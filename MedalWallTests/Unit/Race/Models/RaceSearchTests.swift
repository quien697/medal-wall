//
//  RaceSearchTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-25.
//

import Foundation
import Testing

@testable import MedalWall

struct RaceSearchTests {

  private let vancouver = Place(countryCode: "CA", city: "Vancouver")
  private let newTaipei = Place(countryCode: "TW", city: "New Taipei City")

  private func makeRace(id: String = UUID().uuidString, name: String, place: Place? = nil)
    -> Race
  {
    Race(id: id, name: name, place: place ?? vancouver, createdBy: "user-1")
  }

  // MARK: - Matching
  @Test("A race matches when the query appears anywhere in its name")
  func testMatchesAnywhereInName() {
    let races = [
      makeRace(name: "Taipei Marathon"),
      makeRace(name: "Soochow International Ultramarathon"),
      makeRace(name: "Sun Run")
    ]

    #expect(
      races.matching("marathon").map(\.name) == [
        "Soochow International Ultramarathon", "Taipei Marathon"
      ])
  }

  @Test("A race matches when the query appears in its city")
  func testMatchesCity() {
    let races = [makeRace(name: "Banqiao Night Run", place: newTaipei), makeRace(name: "Sun Run")]

    #expect(races.matching("Taipei").map(\.name) == ["Banqiao Night Run"])
  }

  @Test("A race matches on its country as the app displays it")
  func testMatchesDisplayedCountry() throws {
    let country = try #require(Locale.current.localizedString(forRegionCode: "TW"))
    let races = [makeRace(name: "Banqiao Night Run", place: newTaipei), makeRace(name: "Sun Run")]

    #expect(races.matching(country).map(\.name) == ["Banqiao Night Run"])
  }

  @Test("Matching ignores case and diacritics")
  func testIgnoresCaseAndDiacritics() {
    let races = [makeRace(name: "Zürich Marathon")]

    #expect(races.matching("zurich").map(\.name) == ["Zürich Marathon"])
  }

  @Test("Chinese text matches anywhere in a name")
  func testMatchesChineseAnywhere() {
    let races = [makeRace(name: "田中馬拉松"), makeRace(name: "夜跑")]

    #expect(races.matching("馬拉松").map(\.name) == ["田中馬拉松"])
  }

  @Test("A race matching neither its name nor its place is left out")
  func testExcludesNonMatches() {
    let races = [makeRace(name: "Sun Run"), makeRace(name: "Zürich Marathon")]

    #expect(races.matching("Osaka").isEmpty)
  }

  @Test("A race matching by both name and place is listed once")
  func testMatchByNameAndPlaceListedOnce() {
    let races = [makeRace(name: "New Taipei City Marathon", place: newTaipei)]

    #expect(races.matching("Taipei").map(\.name) == ["New Taipei City Marathon"])
  }

  // MARK: - Ordering
  @Test("Races matching by name come before races matching only by place")
  func testNameMatchesBeforePlaceMatches() {
    let races = [
      makeRace(name: "Banqiao Night Run", place: newTaipei),
      makeRace(name: "Taipei Marathon")
    ]

    #expect(races.matching("Taipei").map(\.name) == ["Taipei Marathon", "Banqiao Night Run"])
  }

  @Test("Each group is sorted A to Z")
  func testEachGroupSortedAlphabetically() {
    let races = [
      makeRace(name: "Taipei Marathon"),
      makeRace(name: "Shuangxi Trail Run", place: newTaipei),
      makeRace(name: "Banqiao Night Run", place: newTaipei),
      makeRace(name: "New Taipei City Wan Jin Shi Marathon")
    ]

    #expect(
      races.matching("Taipei").map(\.name) == [
        "New Taipei City Wan Jin Shi Marathon", "Taipei Marathon",
        "Banqiao Night Run", "Shuangxi Trail Run"
      ])
  }

  @Test("Races sharing a name are ordered by id whatever the input order")
  func testSharedNameOrderedByID() {
    let first = makeRace(id: "a", name: "Taipei Marathon")
    let second = makeRace(id: "b", name: "Taipei Marathon")

    #expect([second, first].matching("Taipei").map(\.id) == ["a", "b"])
    #expect([first, second].matching("Taipei").map(\.id) == ["a", "b"])
  }
}
