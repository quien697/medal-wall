//
//  RaceComputedTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-28.
//

import Testing

@testable import MedalWall

struct RaceComputedTests {
  private let location = GeoLocation(country: "Canada", city: "Vancouver")

  @Test("fullWebsiteUrl is nil when websiteUrl is nil")
  func testFullWebsiteUrlNil() {
    let race = Race(name: "Test Race", location: location, createdBy: "user1")

    #expect(race.fullWebsiteUrl == nil)
  }

  @Test("fullWebsiteUrl returns url unchanged when it already has https scheme")
  func testFullWebsiteUrlAlreadyHttps() {
    let race = Race(
      name: "Test Race", location: location, websiteUrl: "https://example.com", createdBy: "user1")

    #expect(race.fullWebsiteUrl == "https://example.com")
  }

  @Test("fullWebsiteUrl returns url unchanged when it already has http scheme")
  func testFullWebsiteUrlAlreadyHttp() {
    let race = Race(
      name: "Test Race", location: location, websiteUrl: "http://example.com", createdBy: "user1")

    #expect(race.fullWebsiteUrl == "http://example.com")
  }

  @Test("fullWebsiteUrl prepends https when url has no scheme")
  func testFullWebsiteUrlPrependsHttps() {
    let race = Race(
      name: "Test Race", location: location, websiteUrl: "example.com", createdBy: "user1")

    #expect(race.fullWebsiteUrl == "https://example.com")
  }

  @Test("fullWebsiteUrl is nil when websiteUrl is an empty string")
  func testFullWebsiteUrlEmptyString() {
    let race = Race(name: "Test Race", location: location, websiteUrl: "", createdBy: "user1")

    #expect(race.fullWebsiteUrl == nil)
  }
}
