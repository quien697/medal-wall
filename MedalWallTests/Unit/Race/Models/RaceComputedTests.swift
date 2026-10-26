//
//  RaceComputedTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-28.
//

import Testing

@testable import MedalWall

struct RaceComputedTests {
  private let place = Place(countryCode: "CA", city: "Vancouver")

  @Test("fullWebsiteUrl is nil when websiteUrl is nil")
  func testFullWebsiteUrlNil() {
    let race = Race(name: "Test Race", place: place, createdBy: "user1")

    #expect(race.fullWebsiteUrl == nil)
  }

  @Test("fullWebsiteUrl returns url unchanged when it already has https scheme")
  func testFullWebsiteUrlAlreadyHttps() {
    let race = Race(
      name: "Test Race", place: place, websiteUrl: "https://example.com", createdBy: "user1")

    #expect(race.fullWebsiteUrl == "https://example.com")
  }

  @Test("fullWebsiteUrl returns url unchanged when it already has http scheme")
  func testFullWebsiteUrlAlreadyHttp() {
    let race = Race(
      name: "Test Race", place: place, websiteUrl: "http://example.com", createdBy: "user1")

    #expect(race.fullWebsiteUrl == "http://example.com")
  }

  @Test("fullWebsiteUrl prepends https when url has no scheme")
  func testFullWebsiteUrlPrependsHttps() {
    let race = Race(
      name: "Test Race", place: place, websiteUrl: "example.com", createdBy: "user1")

    #expect(race.fullWebsiteUrl == "https://example.com")
  }

  @Test("fullWebsiteUrl is nil when websiteUrl is an empty string")
  func testFullWebsiteUrlEmptyString() {
    let race = Race(name: "Test Race", place: place, websiteUrl: "", createdBy: "user1")

    #expect(race.fullWebsiteUrl == nil)
  }

  @Test("withClampedEditionCounts lifts a negative edition count to zero and keeps the rest")
  func testWithClampedEditionCounts() {
    let races = [
      Race(id: "corrupt", name: "Corrupt", place: place, editionCount: -1, createdBy: "user1"),
      Race(id: "valid", name: "Valid", place: place, editionCount: 3, createdBy: "user1")
    ]

    let clamped = races.withClampedEditionCounts

    #expect(clamped.map(\.id) == ["corrupt", "valid"])
    #expect(clamped.map(\.editionCount) == [0, 3])
  }
}
