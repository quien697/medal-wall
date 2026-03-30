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
  var country: String = ""
  var province: String = ""
  var city: String = ""
  var district: String = ""
  var url: String = ""
  var editions: [DraftRaceEdition] = []
  
  let mode: RaceEditMode
  private var repository: RaceRepository?
  private let race: Race?
  
  init(mode: RaceEditMode, race: Race?) {
    self.mode = mode
    self.race = race
    
    if let race, mode == .edit {
      self.name = race.name
      self.photoData = race.photoData
      self.photo = race.photo
      self.cropPhotoData = race.cropPhotoData
      self.cropPhoto = race.cropPhoto
      self.country = race.location.country
      self.province = race.location.province ?? ""
      self.city = race.location.city
      self.district = race.location.district ?? ""
      self.url = race.url ?? ""
      self.editions = race.editions.map { DraftRaceEdition(from: $0) }
    }
  }
  
  func configure(context: ModelContext) {
    self.repository = RaceRepository(context: context)
  }
  
  var isFormValid: Bool {
    let hasValidName = !name.trimmingCharacters(in: .whitespaces).isEmpty
    let hasValidCountry = !country.trimmingCharacters(in: .whitespaces).isEmpty
    let hasValidCity = !city.trimmingCharacters(in: .whitespaces).isEmpty
    
    return hasValidName && hasValidCountry && hasValidCity
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
  
  var isValidEdition: Bool {
    return true
  }
  
  func updateEdition(old: DraftRaceEdition, with new: DraftRaceEdition) throws {
    guard isFormValid else {
      throw AppError.duplicateEdition
    }
    
    if let index = editions.firstIndex(where: { $0.id == old.id }) {
      editions[index] = new
    }
  }
  
  func addEdition(_ edition: DraftRaceEdition) {
    editions.append(edition)
  }
  
  /// Applies the draft changes to the model
  /// - Throws: AppError if repository is not configured or save fails
  func save(by userId: UUID) throws {
    guard let repository else { throw AppError.contextNotAttached }
    
    if let race = race {
      // Edit mode: apply draft changes to the existing race
      race.name = name
      race.photoData = photoData
      race.cropPhotoData = cropPhotoData
      race.country = country
      race.province = province.isEmpty ? nil : province
      race.city = city
      race.district = district.isEmpty ? nil : district
      race.url = url.isEmpty ? nil : url
      race.updatedDate = .now
      
      let sourceEditionIds = Set(editions.compactMap { $0.sourceEditionId })
      
      // Delete editions removed from the draft list
      for edition in race.editions where !sourceEditionIds.contains(edition.id) {
        try repository.deleteEdition(edition)
      }
      
      // Update existing editions and add new ones
      for draftEdition in editions {
        if let sourceId = draftEdition.sourceEditionId,
           let edition = race.editions.first(where: { $0.id == sourceId }) {
          edition.year = draftEdition.year
          edition.startDate = draftEdition.startDate
          edition.endDate = draftEdition.endDate
          edition.photoData = draftEdition.photoData
          edition.cropPhotoData = draftEdition.cropPhotoData
          edition.updatedDate = .now
        } else {
          let newEdition = RaceEdition(
            year: draftEdition.year,
            startDate: draftEdition.startDate,
            endDate: draftEdition.endDate,
            photoData: draftEdition.photoData,
            cropPhotoData: draftEdition.cropPhotoData,
            createBy: userId,
            race: race,
            categories: []
          )
          
          try repository.insertEdition(newEdition, to: race)
        }
      }
    } else {
      // Add mode: create new race
      let newRace = Race(
        name: name,
        photoData: photoData,
        cropPhotoData: cropPhotoData,
        location: RaceLocation(
          country: country,
          province: province.isEmpty ? nil : province,
          city: city,
          district: district.isEmpty ? nil : district
        ),
        url: url.isEmpty ? nil : url,
        createBy: userId
      )
      try repository.insertRace(newRace)
      
      // Create editions for the new race
      for edition in editions {
        let newEdition = RaceEdition(
          year: edition.year,
          startDate: edition.startDate,
          endDate: edition.endDate,
          photoData: edition.photoData,
          cropPhotoData: edition.cropPhotoData,
          createBy: userId,
          race: newRace,
          categories: []
        )
        try repository.insertEdition(newEdition, to: newRace)
      }
    }
    
    try repository.save()
  }
}
