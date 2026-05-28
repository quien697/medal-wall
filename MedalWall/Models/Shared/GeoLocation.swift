//
//  GeoLocation.swift
//  MedalWall
//
//  Created by Quien on 2026-05-18.
//

/// Represents a geographic location described by administrative region fields.
struct GeoLocation: Codable, Hashable, Sendable {
  var country: String
  var province: String?
  var city: String
  var district: String?

  var formatted: String {
    var parts: [String] = []

    if let district, !district.isEmpty {
      parts.append(district)
    }

    parts.append(city)

    if let province, !province.isEmpty {
      parts.append(province)
    }

    parts.append(country)

    return parts.joined(separator: ", ")
  }
}
