//
//  RaceLocation.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

nonisolated
struct RaceLocation: Codable, Hashable, Sendable {
  var country: String
  var province: String?
  var city: String
  var district: String?
  var postalCode: String?
  
  var formatted: String {
    if let province = province {
      return "\(city), \(province), \(country)"
    } else {
      return "\(city), \(country)"
    }
  }
}
