//
//  Place.swift
//  MedalWall
//
//  Created by Quien on 2026-04-24.
//

struct Place: Codable, Hashable, Sendable {
  var country: String
  var province: String?
  var city: String
  var district: String?
  var latitude: Double?
  var longitude: Double?
  
  init(
    country: String,
    province: String? = nil,
    city: String,
    district: String? = nil,
    latitude: Double? = nil,
    longitude: Double? = nil
  ) {
    self.country = country
    self.province = province
    self.city = city
    self.district = district
    self.latitude = latitude
    self.longitude = longitude
  }
  
  var formatted: String {
    var parts: [String] = []
    if let district, !district.isEmpty { parts.append(district) }
    parts.append(city)
    if let province, !province.isEmpty { parts.append(province) }
    parts.append(country)
    return parts.joined(separator: ", ")
  }
}
