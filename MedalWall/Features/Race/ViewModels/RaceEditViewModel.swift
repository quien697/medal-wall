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
  var name: String
  var photo: String
  var date: Date
  var country: String
  var province: String
  var city: String
  var district: String
  var url: String
  var updateTime: Date
  var categories: [RaceCategory]
  var isNewRace: Bool
  
  private let context: ModelContext
  private var race: Race?
  
  init(race: Race?, context: ModelContext) {
    self.context = context
    
    if let race {
      self.race = race
      self.name = race.name
      self.photo = race.photo ?? ""
      self.date = race.date
      self.country = race.location.country
      self.province = race.location.province ?? ""
      self.city = race.location.city
      self.district = race.location.district ?? ""
      self.url = race.url ?? ""
      self.updateTime = race.updateTime
      self.categories = race.categories
      self.isNewRace = false
    } else {
      self.name = ""
      self.photo = ""
      self.date = Date()
      self.country = ""
      self.province = ""
      self.city = ""
      self.district = ""
      self.url = ""
      self.updateTime = Date()
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
    if let race {
      race.name = name
      race.photo = photo.isEmpty ? nil : photo
      race.date = date
      race.country = country
      race.province = province.isEmpty ? nil : province
      race.city = city
      race.district = district.isEmpty ? nil : province
      race.url = url.isEmpty ? nil : url
      race.updateTime = Date()
      race.categories = categories
    } else {
      let newRace = Race(
        name: name,
        date: date,
        location: RaceLocation(country: country, city: city),
        url: url.isEmpty ? nil : url,
        updateTime: updateTime,
        categories: categories
      )
      
      context.insert(newRace)
    }
    
    try context.save()
  }
}
