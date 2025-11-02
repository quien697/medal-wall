//
//  RaceEditViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-11-02.
//

import SwiftUI
import SwiftData

@Observable
class RaceEditViewModel {
  var id: UUID
  var name: String
  var date: Date
  var country: String
  var province: String
  var city: String
  var district: String
  var postalCode: String
  var url: String
  var isOfficial: Bool
  var categories: [RaceCategory]
  var isNewRace: Bool
  
  private let context: ModelContext
  private var race: Race?
  
  init(race: Race?, context: ModelContext) {
    self.context = context
    
    if let race {
      self.race = race
      self.id = race.id
      self.name = race.name
      self.date = race.date
      self.country = race.location.country
      self.province = race.location.province ?? ""
      self.city = race.location.city
      self.district = race.location.district ?? ""
      self.postalCode = race.location.postalCode ?? ""
      self.url = race.url ?? ""
      self.isOfficial = race.isOfficial
      self.categories = race.categories
      self.isNewRace = false
    } else {
      self.id = UUID()
      self.name = ""
      self.date = Date()
      self.country = ""
      self.province = ""
      self.city = ""
      self.district = ""
      self.postalCode = ""
      self.url = ""
      self.isOfficial = true
      self.categories = []
      self.isNewRace = true
    }
  }
  
  var isFormValid: Bool {
    !name.trimmingCharacters(in: .whitespaces).isEmpty &&
    !country.trimmingCharacters(in: .whitespaces).isEmpty &&
    !city.trimmingCharacters(in: .whitespaces).isEmpty
  }
  
  func save() throws {
    let location = RaceLocation(
      country: country,
      province: province.isEmpty ? nil : province,
      city: city,
      district: district.isEmpty ? nil : district,
      postalCode: postalCode.isEmpty ? nil : postalCode
    )
    
    if let race {
      race.name = name
      race.date = date
      race.location = location
      race.url = url.isEmpty ? nil : url
      race.isOfficial = isOfficial
      race.categories = categories
    } else {
      let newRace = Race(
        id: id,
        name: name,
        date: date,
        location: location,
        url: url.isEmpty ? nil : url,
        categories: categories
      )
      
      context.insert(newRace)
    }
    
    try context.save()
  }
}
