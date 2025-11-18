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
      self.distances = race.distances
      self.isNewRace = false
    }
  }
  
  var isFormValid: Bool {
    !name.trimmingCharacters(in: .whitespaces).isEmpty &&
    !country.trimmingCharacters(in: .whitespaces).isEmpty &&
    !city.trimmingCharacters(in: .whitespaces).isEmpty
  }
  
  func addDistance(_ distance: RaceDistance) {
    distances.append(distance)
  }
  
  func deleteDistance(at offsets: IndexSet) {
    distances.remove(atOffsets: offsets)
  }
  
  func save() throws {
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

extension RaceEditViewModel {
  
  func binding(for distance: RaceDistance) -> Binding<RaceDistance> {
    guard let index = distances.firstIndex(of: distance) else {
      assertionFailure("Binding not found for distance \(distance)")
      return .constant(distance)
    }
    
    return Binding(
      get: { self.distances[index] },
      set: { self.distances[index] = $0 }
    )
  }
}
