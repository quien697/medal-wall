//
//  EditRaceViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-11-02.
//

import SwiftUI
import SwiftData

@Observable
final class EditRaceViewModel {
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
  
  let mode: ItemEditMode
  private var repository: RaceRepository
  private let race: Race?
  
  init(mode: ItemEditMode, race: Race?) {
    self.mode = mode
    self.repository = RaceRepository()
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
      self.url = race.fullURL ?? ""
      self.editions = race.editions.map { DraftRaceEdition(from: $0) }
    }
  }
  
  func configure(context: ModelContext) {
    repository.configure(context: context)
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
  
  func deleteEdition(_ edition: DraftRaceEdition) {
    editions.removeAll { $0.id == edition.id }
  }
  
  /// Syncs categories on an existing edition by diffing against draft distances.
  /// Only deletes removed categories and inserts new ones.
  /// Syncs editions on an existing race by diffing against drafts.
  /// Deletes removed editions, updates existing ones, and adds new ones.
  private func syncEditions(on race: Race, with drafts: [DraftRaceEdition], by userId: UUID) throws {
    let sourceEditionIds = Set(drafts.compactMap { $0.sourceEditionId })
    
    // Delete editions removed from the draft list
    for edition in race.editions where !sourceEditionIds.contains(edition.id) {
      try repository.deleteEdition(edition)
    }
    
    // Update existing editions and add new ones
    for draft in drafts {
      if let sourceId = draft.sourceEditionId,
         let edition = race.editions.first(where: { $0.id == sourceId }) {
        edition.year = draft.year
        edition.startDate = draft.startDate
        edition.endDate = draft.endDate
        edition.photoData = draft.photoData
        edition.cropPhotoData = draft.cropPhotoData
        edition.updatedDate = .now
        
        try syncCategories(on: edition, with: draft.distances)
      } else {
        let newEdition = RaceEdition(
          year: draft.year,
          startDate: draft.startDate,
          endDate: draft.endDate,
          photoData: draft.photoData,
          cropPhotoData: draft.cropPhotoData,
          createBy: userId,
          race: race,
          categories: []
        )
        
        try syncCategories(on: newEdition, with: draft.distances)
        try repository.insertEdition(newEdition, to: race)
      }
    }
  }
  
  /// Syncs categories on an edition by diffing against draft distances.
  /// Only deletes removed categories and inserts new ones.
  private func syncCategories(on edition: RaceEdition, with draftDistances: [RaceDistance]) throws {
    // Delete categories no longer in draft
    for category in edition.categories {
      let distance = RaceDistance(
        category: RaceDistanceCategory(value: category.distance),
        type: RaceDistanceType(rawValue: category.type) ?? .inPerson
      )
      if !draftDistances.contains(distance) {
        try repository.deleteCategory(category)
      }
    }
    
    // Add new distances as categories
    for distance in draftDistances where !edition.distances.contains(distance) {
      let category = RaceCategory(distance: distance, raceEdition: edition)
      try repository.insertCategory(category, to: edition)
    }
  }
  
  /// Applies the draft changes to the model
  /// - Throws: AppError if repository is not configured or save fails
  func save(by userId: UUID) throws {
    let race = if let race = self.race {
      race
    } else {
      Race(
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
    }
    
    if self.race == nil {
      try repository.insertRace(race)
    } else {
      race.name = name
      race.photoData = photoData
      race.cropPhotoData = cropPhotoData
      race.country = country
      race.province = province
      race.city = city
      race.district = district
      race.url = url.isEmpty ? nil : url
      race.updatedDate = .now
    }
    
    try syncEditions(on: race, with: editions, by: userId)
    try repository.save()
  }
}
