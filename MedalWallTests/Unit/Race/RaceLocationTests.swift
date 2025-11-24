//
//  RaceLocationTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-17.
//

import Testing
@testable import MedalWall

struct RaceLocationTests {
  
  @Test("Formatted string includes district, city, province and country when all exist")
  func formattedFullLocation() {
    let location = RaceLocation(
      country: "Taiwan",
      province: "Taiwan",
      city: "New Taipei City",
      district: "Wanli"
    )
    
    #expect(location.formatted == "Wanli, New Taipei City, Taiwan, Taiwan")
  }
  
  @Test("Formatted string ignores province when nil")
  func formattedWithoutProvince() {
    let loc = RaceLocation(
      country: "Taiwan",
      province: nil,
      city: "Taipei",
      district: "Xinyi",
    )
    
    #expect(loc.formatted == "Xinyi, Taipei, Taiwan")
  }
  
  @Test("Formatted string ignores district when nil")
  func formattedWithoutDistrict() {
    let loc = RaceLocation(
      country: "Canada",
      province: "AB",
      city: "Banff",
      district: nil,
    )
    
    #expect(loc.formatted == "Banff, AB, Canada")
  }
  
  @Test("Formatted string ignores district and province when nil")
  func formattedWithoutProvinceAndDistrict() {
    let loc = RaceLocation(
      country: "Japan",
      province: nil,
      city: "Osaka",
      district: nil,
    )
    
    #expect(loc.formatted == "Osaka, Japan")
  }
}
