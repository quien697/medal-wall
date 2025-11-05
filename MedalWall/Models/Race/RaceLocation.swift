//
//  RaceLocation.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

/// Represents the location of race event
struct RaceLocation: Codable, Hashable, Sendable {
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
