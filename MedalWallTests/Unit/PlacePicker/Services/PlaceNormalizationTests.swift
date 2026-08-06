//
//  PlaceNormalizationTests.swift
//  MedalWall
//
//  Created by Quien on 2026-08-06.
//

import Foundation
import Testing

@testable import MedalWall

/// Pins `MapKitPlaceSearchService.place(...)` to values actually observed from MapKit,
/// so the city-level rule cannot regress silently. The service's networking is not tested;
/// only this mapping is, which is why it takes strings rather than an `MKMapItem`.
@MainActor
struct PlaceNormalizationTests {

  // MARK: - Helpers
  private func normalize(
    _ isoCountryCode: String?,
    admin: String?,
    subAdmin: String?,
    locality: String?
  ) -> Place {
    MapKitPlaceSearchService.place(
      isoCountryCode: isoCountryCode,
      administrativeArea: admin,
      subAdministrativeArea: subAdmin,
      locality: locality
    )
  }

  // MARK: - Taiwan promotes the administrative area to city
  @Test("A Taiwanese district resolves to its city, not the district")
  func testTaiwanDistrictPromotesToCity() {
    let place = normalize(
      "TW", admin: "Taoyuan City", subAdmin: "Taoyuan City", locality: "Taoyuan District")

    #expect(place.city == "Taoyuan City")
    #expect(place.region == nil)
    #expect(place.formatted(in: Locale(identifier: "en_US")) == "Taoyuan City, Taiwan")
  }

  @Test("A Taiwanese township resolves to its county")
  func testTaiwanTownshipPromotesToCounty() {
    let place = normalize(
      "TW", admin: "Changhua County", subAdmin: "Changhua County",
      locality: "Tianzhong Township")

    #expect(place.city == "Changhua County")
    #expect(place.region == nil)
  }

  @Test("A Taiwanese city-level result with no locality still yields a city")
  func testTaiwanCityLevelResult() {
    let place = normalize("TW", admin: "Taipei City", subAdmin: "Taipei City", locality: nil)

    #expect(place.city == "Taipei City")
    #expect(place.region == nil)
  }

  // MARK: - Elsewhere the provider's own split is kept
  @Test("A US city keeps its state as the region")
  func testUnitedStatesKeepsState() {
    let place = normalize(
      "US", admin: "OR", subAdmin: "Multnomah County", locality: "Portland")

    #expect(place.city == "Portland")
    #expect(place.region == "OR")
  }

  @Test("A Canadian city keeps its province as the region")
  func testCanadaKeepsProvince() {
    let place = normalize(
      "CA", admin: "BC", subAdmin: "Metro Vancouver", locality: "Vancouver")

    #expect(place.city == "Vancouver")
    #expect(place.region == "BC")
  }

  @Test("A Japanese ward keeps its prefecture as the region")
  func testJapanKeepsPrefecture() {
    let place = normalize("JP", admin: "Tokyo", subAdmin: nil, locality: "Shinjuku")

    #expect(place.city == "Shinjuku")
    #expect(place.region == "Tokyo")
  }

  // MARK: - Degenerate provider data
  @Test("An absent locality promotes the administrative area rather than leaving city empty")
  func testAbsentLocalityPromotesArea() {
    let place = normalize("JP", admin: "Tokyo", subAdmin: nil, locality: nil)

    #expect(place.city == "Tokyo")
    #expect(place.region == nil)
    #expect(place.isValid)
  }

  @Test("A region repeating the country code is dropped")
  func testRegionEqualToCountryCodeIsDropped() {
    let place = normalize("SG", admin: "SG", subAdmin: nil, locality: "Singapore")

    #expect(place.city == "Singapore")
    #expect(place.region == nil)
    #expect(place.formatted(in: Locale(identifier: "en_US")) == "Singapore, Singapore")
  }

  @Test("A region repeating the city is dropped")
  func testRegionEqualToCityIsDropped() {
    let place = normalize("XX", admin: "Metropolis", subAdmin: nil, locality: "Metropolis")

    #expect(place.city == "Metropolis")
    #expect(place.region == nil)
  }
}
