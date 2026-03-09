//
//  RaceEditViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-11-02.
//

import SwiftUI
import SwiftData

@Observable
final class RaceEditViewModel {
  var name: String = ""
  var photoData: Data? = nil
  var photo: UIImage? = nil
  var cropPhotoData: Data? = nil
  var cropPhoto: UIImage? = nil
//  var date: Date = .now
  var country: String = ""
  var province: String = ""
  var city: String = ""
  var district: String = ""
  var url: String = ""
  var updateTime: Date = .now
  var distances: [RaceDistance] = []
  var isNewRace: Bool = true
  
  private let repository: RaceRepository
  private(set) var race: Race?
  
  init(race: Race?, repository: RaceRepository = RaceRepository()) {
    self.repository = repository
    self.race = race
    
    if let race {
      self.race = race
      self.name = race.name
      self.photoData = race.photoData
      self.photo = race.photo
      self.cropPhotoData = race.cropPhotoData
      self.cropPhoto = race.cropPhoto
//      self.date = race.date
      self.country = race.location.country
      self.province = race.location.province ?? ""
      self.city = race.location.city
      self.district = race.location.district ?? ""
      self.url = race.url ?? ""
//      self.updateTime = race.updateTime
//      self.distances = race.distances
      self.isNewRace = false
    }
  }
  
  func attachContext(_ context: ModelContext) throws {
    repository.attachContext(context)
  }
  
  var isFormValid: Bool {
    !name.trimmingCharacters(in: .whitespaces).isEmpty &&
    !country.trimmingCharacters(in: .whitespaces).isEmpty &&
    !city.trimmingCharacters(in: .whitespaces).isEmpty
  }
  
  func updatePhoto(with data: Data?) {
    self.photoData = data
    
    if let data {
      self.photo = UIImage(data: data)
    } else {
      self.photo = nil
    }
  }
  
  func updateCropPhoto(with uiImage: UIImage) {
    self.cropPhotoData = uiImage.pngData()
    self.cropPhoto = uiImage
  }
  
  func clearPhoto() {
    self.photoData = nil
    self.photo = nil
    self.cropPhotoData = nil
    self.cropPhoto = nil
  }
  
  func addDistance(_ distance: RaceDistance) throws {
    if distances.contains(distance) {
      throw AppError.duplicateDistance
    } else {
      distances.append(distance)
    }
  }
  
  func updateDistance(old: RaceDistance, with new: RaceDistance) throws {
    if distances.contains(new) {
      throw AppError.duplicateDistance
    } else {
      if let index = distances.firstIndex(of: old) {
        distances[index] = new
      }
    }
  }
  
  func deleteDistance(_ distance: RaceDistance) {
    if let index = distances.firstIndex(of: distance) {
      distances.remove(at: index)
    }
  }
  
  func save() throws {
    if let race {
      race.name = name
      race.photoData = photoData
      race.cropPhotoData = cropPhotoData
//      race.date = date
      race.country = country
      race.province = province.isEmpty ? nil : province
      race.city = city
      race.district = district.isEmpty ? nil : district
      race.url = url.isEmpty ? nil : url
//      for category in race.categories {
//        try repository.deleteCategory(category)
//      }
//      race.categories = distances.map {
//        RaceCategory(distance: $0, race: race)
//      }
    } else {
      let newRace = Race(
        name: name,
        photoData: photoData,
        cropPhotoData: cropPhotoData,
//        date: date,
        location: RaceLocation(
          country: country,
          province: province.isEmpty ? nil : province,
          city: city,
          district: district.isEmpty ? nil : district
        ),
        url: url.isEmpty ? nil : url, createBy: UUID(),
      )
//      newRace.categories = distances.map {
//        RaceCategory(distance: $0, race: newRace)
//      }
      
      try repository.insertRace(newRace)
    }
    
    try repository.save()
  }
}
