//
//  MedalSearchTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-25.
//

import Foundation
import Testing

@testable import MedalWall

struct MedalSearchTests {

  private let vancouver = Place(countryCode: "CA", city: "Vancouver")

  private func makeDate(_ year: Int, _ month: Int, _ day: Int) -> Date {
    var components = DateComponents()
    components.year = year
    components.month = month
    components.day = day
    components.hour = 12
    return Calendar.current.date(from: components) ?? .now
  }

  private func makeMedal(
    id: String = UUID().uuidString,
    name: String = "Test",
    date: Date = .now,
    place: Place? = nil
  ) -> Medal {
    Medal(
      id: id,
      name: name,
      date: date,
      bibNumber: "1",
      place: place ?? vancouver,
      raceEvent: RaceEvent(category: .full, type: .inPerson),
      userID: "user1"
    )
  }

  // MARK: - Matching
  @Test("A medal matches when the query appears anywhere in its name")
  func testMatchesAnywhereInName() {
    let medals = [
      makeMedal(id: "ultra", name: "Soochow International Ultramarathon"),
      makeMedal(id: "run", name: "Sun Run")
    ]

    #expect(medals.matching("marathon").map(\.id) == ["ultra"])
  }

  @Test("A medal matches when the query appears in its city")
  func testMatchesCity() {
    let newTaipei = Place(countryCode: "TW", city: "New Taipei City")
    let medals = [
      makeMedal(id: "banqiao", name: "Banqiao Night Run", place: newTaipei),
      makeMedal(id: "sun", name: "Sun Run")
    ]

    #expect(medals.matching("Taipei").map(\.id) == ["banqiao"])
  }

  @Test("A medal matches on its country as the app displays it")
  func testMatchesDisplayedCountry() throws {
    let country = try #require(Locale.current.localizedString(forRegionCode: "TW"))
    let changhua = Place(countryCode: "TW", city: "Changhua County")
    let medals = [
      makeMedal(id: "taiwan", name: "Night Run", place: changhua),
      makeMedal(id: "canada", name: "Sun Run")
    ]

    #expect(medals.matching(country).map(\.id) == ["taiwan"])
  }

  @Test("Matching ignores case and diacritics")
  func testIgnoresCaseAndDiacritics() {
    let medals = [makeMedal(id: "zurich", name: "Zürich Marathon")]

    #expect(medals.matching("zurich").map(\.id) == ["zurich"])
  }

  @Test("Chinese text matches anywhere in a name")
  func testMatchesChineseAnywhere() {
    let medals = [
      makeMedal(id: "tianzhong", name: "田中馬拉松"),
      makeMedal(id: "other", name: "太魯閣峽谷馬拉松路跑"),
      makeMedal(id: "night", name: "夜跑")
    ]

    #expect(Set(medals.matching("馬拉松").map(\.id)) == ["tianzhong", "other"])
  }

  @Test("A medal matching neither its name nor its place is left out")
  func testExcludesNonMatches() {
    let medals = [makeMedal(name: "Sun Run"), makeMedal(name: "Zürich Marathon")]

    #expect(medals.matching("Osaka").isEmpty)
  }

  // MARK: - Ordering
  @Test("Matches come back most recent first")
  func testMatchesMostRecentFirst() {
    let medals = [
      makeMedal(id: "2017", name: "Marathon", date: makeDate(2017, 4, 1)),
      makeMedal(id: "2019", name: "Marathon", date: makeDate(2019, 4, 1)),
      makeMedal(id: "2018", name: "Marathon", date: makeDate(2018, 4, 1))
    ]

    #expect(medals.matching("Marathon").map(\.id) == ["2019", "2018", "2017"])
  }

  @Test("Matches sharing a date are ordered by id")
  func testMatchesSharingADateOrderedByID() {
    let sharedDate = makeDate(2022, 5, 1)
    let medals = [
      makeMedal(id: "b", name: "Marathon", date: sharedDate),
      makeMedal(id: "a", name: "Marathon", date: sharedDate)
    ]

    #expect(medals.matching("Marathon").map(\.id) == ["a", "b"])
  }
}
