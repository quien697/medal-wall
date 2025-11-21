//
//  RaceEditViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-11-02.
//

import SwiftUI
import SwiftData

enum RaceEditError: LocalizedError {
  case duplicateDistance
}

@Observable
class RaceEditViewModel {
  var name: String = ""
  var photo: String = ""
  var date: Date = .now
  var country: String = ""
  var province: String = ""
  var city: String = ""
  var district: String = ""
  var url: String = ""
  var updateTime: Date = .now
  var distances: [RaceDistance] = []
  var isNewRace: Bool = true
  
  private var context: ModelContext?
  private(set) var race: Race?
  
  init(race: Race?) {
    self.race = race
    
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
      self.distances = race.distances
      self.isNewRace = false
    }
  }
  
  func attachContext(_ context: ModelContext) {
    self.context = context
  }
  
  var isFormValid: Bool {
    !name.trimmingCharacters(in: .whitespaces).isEmpty &&
    !country.trimmingCharacters(in: .whitespaces).isEmpty &&
    !city.trimmingCharacters(in: .whitespaces).isEmpty
  }
  
  func addDistance(_ distance: RaceDistance) throws {
    if distances.contains(distance) {
      throw RaceEditError.duplicateDistance
    } else {
      distances.append(distance)
    }
  }
  
  func updateDistance(old: RaceDistance, with new: RaceDistance) throws {
    if distances.contains(new) {
      throw RaceEditError.duplicateDistance
    } else {
      if let index = distances.firstIndex(of: old) {
        distances[index] = new
      }
    }
  }
  
  func deleteDistance(at offsets: IndexSet) {
    distances.remove(atOffsets: offsets)
  }
  
  func save() throws {
    guard let context else { return }
    
    if let race {
      race.name = name
      race.photo = photo.isEmpty ? nil : photo
      race.date = date
      race.country = country
      race.province = province.isEmpty ? nil : province
      race.city = city
      race.district = district.isEmpty ? nil : district
      race.url = url.isEmpty ? nil : url
      race.updateTime = .now
      for category in race.categories {
        context.delete(category)
      }
      race.categories = distances.map {
        RaceCategory(distance: $0, race: race)
      }
    } else {
      let newRace = Race(
        name: name,
        date: date,
        location: RaceLocation(country: country, city: city),
        url: url.isEmpty ? nil : url,
      )
      newRace.categories = distances.map {
        RaceCategory(distance: $0, race: newRace)
      }
      
      context.insert(newRace)
    }
    
    try context.save()
  }
}
