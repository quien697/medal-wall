//
//  PlaceTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-29.
//

import Foundation
import Testing

@testable import MedalWall

struct PlaceTests {

  private static let english = Locale(identifier: "en_US")

  // MARK: - Codable
  @Test("A place survives an encode/decode round-trip")
  func testRoundTrip() throws {
    let place = Place(countryCode: "TW", city: "彰化縣")

    let decoded = try JSONDecoder().decode(Place.self, from: JSONEncoder().encode(place))

    #expect(decoded == place)
  }

  @Test("An absent region is omitted when encoding")
  func testAbsentRegionIsOmitted() throws {
    let place = Place(countryCode: "TW", city: "臺北市")

    let encoded = try JSONEncoder().encode(place)
    let object = try JSONSerialization.jsonObject(with: encoded) as? [String: Any]
    let keys = try #require(object).keys

    #expect(keys.contains("countryCode"))
    #expect(keys.contains("city"))
    #expect(!keys.contains("region"))
    #expect(keys.count == 2)
  }

  // MARK: - isValid
  @Test("A place needs both a country code and a city to be valid")
  func testIsValidRequiresBothFields() {
    #expect(Place(countryCode: "TW", city: "臺北市").isValid)
    #expect(Place(countryCode: "", city: "臺北市").isValid == false)
    #expect(Place(countryCode: "TW", city: "").isValid == false)
    #expect(Place(countryCode: "  ", city: "  ").isValid == false)
  }

  // MARK: - Locale-aware display
  @Test("A place with a region renders city, region, and country")
  func testFormattedWithRegion() {
    let place = Place(countryCode: "US", city: "Portland", region: "OR")

    #expect(place.formatted(in: Self.english) == "Portland, OR, United States")
  }

  @Test("A place without a region renders city and country only")
  func testFormattedWithoutRegion() {
    let place = Place(countryCode: "TW", city: "Changhua County")

    #expect(place.formatted(in: Self.english) == "Changhua County, Taiwan")
  }

  @Test("Absent components leave no empty separator")
  func testFormattedOmitsAbsentComponents() {
    #expect(
      Place(countryCode: "TW", city: "", region: "Taipei City")
        .formatted(in: Self.english) == "Taipei City, Taiwan")
    #expect(
      Place(countryCode: "", city: "Metropolis", region: "Poseidia")
        .formatted(in: Self.english) == "Metropolis, Poseidia")
  }

  @Test("The country renders in the viewer's own language")
  func testFormattedLocalizesCountry() {
    let place = Place(countryCode: "TW", city: "臺北市")
    let chinese = place.formatted(in: Locale(identifier: "zh_TW"))

    #expect(chinese.hasSuffix("台灣") || chinese.hasSuffix("臺灣"))
  }
}
