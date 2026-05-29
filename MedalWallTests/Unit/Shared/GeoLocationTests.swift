//
//  GeoLocationTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-29.
//

import Testing

@testable import MedalWall

struct GeoLocationTests {

  @Test("formatted includes all fields when all are set")
  func testFormattedAllFields() {
    let location = GeoLocation(
      country: "Canada",
      province: "BC",
      city: "Vancouver",
      district: "Kitsilano"
    )

    #expect(location.formatted == "Kitsilano, Vancouver, BC, Canada")
  }

  @Test("formatted includes only city and country when province and district are nil")
  func testFormattedCountryAndCityOnly() {
    let location = GeoLocation(country: "Canada", city: "Vancouver")

    #expect(location.formatted == "Vancouver, Canada")
  }

  @Test("formatted includes province but omits district when district is nil")
  func testFormattedWithProvinceNoDistrict() {
    let location = GeoLocation(country: "Canada", province: "BC", city: "Vancouver")

    #expect(location.formatted == "Vancouver, BC, Canada")
  }

  @Test("formatted includes district but omits province when province is nil")
  func testFormattedWithDistrictNoProvince() {
    let location = GeoLocation(country: "Canada", city: "Vancouver", district: "Kitsilano")

    #expect(location.formatted == "Kitsilano, Vancouver, Canada")
  }

  @Test("formatted omits province when it is an empty string")
  func testFormattedEmptyProvince() {
    let location = GeoLocation(country: "Canada", province: "", city: "Vancouver")

    #expect(location.formatted == "Vancouver, Canada")
  }

  @Test("formatted omits district when it is an empty string")
  func testFormattedEmptyDistrict() {
    let location = GeoLocation(country: "Canada", city: "Vancouver", district: "")

    #expect(location.formatted == "Vancouver, Canada")
  }

  @Test("formatted order is district, city, province, country")
  func testFormattedOrder() {
    let location = GeoLocation(
      country: "Japan",
      province: "Tokyo",
      city: "Shinjuku",
      district: "Kabukicho"
    )

    #expect(location.formatted == "Kabukicho, Shinjuku, Tokyo, Japan")
  }
}
