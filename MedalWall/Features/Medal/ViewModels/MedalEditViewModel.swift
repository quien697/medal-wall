//
//  MedalEditViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-12-21.
//

import SwiftUI
import SwiftData

@Observable
final class MedalEditViewModel {
  var title: String = ""
  var date: Date = .now
  var result: String = ""
  var photoData: Data? = nil
  var photo: UIImage? = nil
  var cropPhotoData: Data? = nil
  var cropPhoto: UIImage? = nil
  var note: String = ""
  var user: User? = nil
  var selectedRaceID: UUID? = nil
  var selectedRaceCategoryID: UUID? = nil
  var isNewMedal: Bool = true

  private let repository: MedalRepository
  private(set) var medal: Medal?

  init(medal: Medal?, user: User? = nil, repository: MedalRepository = MedalRepository()) {
    self.medal = medal
    self.user = user
    self.repository = repository

    if let medal {
      self.title = medal.title
      self.date = medal.date
      self.result = medal.result ?? ""
      self.photoData = medal.photoData
      self.photo = medal.photo
      self.cropPhotoData = medal.cropPhotoData
      self.cropPhoto = medal.cropPhoto
      self.note = medal.note ?? ""
      self.user = medal.user
//      self.selectedRaceID = medal.raceCategory.race.id
//      self.selectedRaceCategoryID = medal.raceCategory.id
      self.isNewMedal = false
    }
  }

  func attachContext(_ context: ModelContext) throws {
    repository.attachContext(context)
  }

  var isFormValid: Bool {
    !title.trimmingCharacters(in: .whitespaces).isEmpty &&
    (user != nil) &&
    (selectedRaceCategoryID != nil)
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

  func save(in context: ModelContext) throws {
    if let medal {
      medal.title = title
      medal.date = date
      medal.result = result.isEmpty ? nil : result
      medal.photoData = photoData
      medal.cropPhotoData = cropPhotoData
      medal.note = note.isEmpty ? nil : note

//      if let categoryID = selectedRaceCategoryID {
//        let categories = try context.fetch(FetchDescriptor<RaceCategory>())
//        if let newCategory = categories.first(where: { $0.id == categoryID }) {
//          medal.raceCategory = newCategory
//        }
//      }
    } else {
      guard let user = user else { throw AppError.unknown }
      guard let categoryID = selectedRaceCategoryID else { throw AppError.unknown }
      let categories = try context.fetch(FetchDescriptor<RaceCategory>())
      guard let category = categories.first(where: { $0.id == categoryID }) else { throw AppError.unknown }
      
      let newMedal = Medal(
        title: title,
        date: date,
        location: "",
        result: result.isEmpty ? nil : result,
        photoData: photoData,
        cropPhotoData: cropPhotoData,
        note: note.isEmpty ? nil : note,
        user: user,
        raceCategory: category
      )

      context.insert(newMedal)
    }

    try context.save()
  }
}
