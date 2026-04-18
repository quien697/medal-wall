//
//  EditMedalViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-12-21.
//

import SwiftUI
import SwiftData

@Observable
final class EditMedalViewModel {
  var name: String = ""
  var date: Date = .now
  var bibNumber: String = ""
  var photoData: Data? = nil
  var photo: UIImage? = nil
  var cropPhotoData: Data? = nil
  var cropPhoto: UIImage? = nil
  var country: String = ""
  var province: String = ""
  var city: String = ""
  var district: String = ""
  var distance: RaceDistance = .default
  var finishTime: TimeInterval? = nil
  var overallPlacement: Int? = nil
  var totalParticipants: Int? = nil
  var division: Division? = nil
  var divisionPlacement: Int? = nil
  var divisionTotal: Int? = nil
  var genderPlacement: Int? = nil
  var genderTotal: Int? = nil
  var note: String = ""
  var tags: [String] = []
  var draftEventPhotos: [DraftEventPhoto] = []
  
  let mode: ItemEditMode
  private var repository: MedalRepository
  private let medal: Medal?
  
  init(mode: ItemEditMode, medal: Medal? = nil) {
    self.mode = mode
    self.repository = MedalRepository()
    self.medal = medal
    
    if let medal, mode == .edit {
      self.name = medal.name
      self.date = medal.date
      self.bibNumber = medal.bibNumber
      self.photoData = medal.photoData
      self.photo = medal.photo
      self.cropPhotoData = medal.cropPhotoData
      self.cropPhoto = medal.cropPhoto
      self.country = medal.location.country
      self.province = medal.location.province ?? ""
      self.city = medal.location.city
      self.district = medal.location.district ?? ""
      self.distance = medal.distance
      self.finishTime = medal.finishTime
      self.overallPlacement = medal.overallPlacement
      self.totalParticipants = medal.totalParticipants
      self.division = medal.divisionEnum
      self.divisionPlacement = medal.divisionPlacement
      self.divisionTotal = medal.divisionTotal
      self.genderPlacement = medal.genderPlacement
      self.genderTotal = medal.genderTotal
      self.note = medal.note ?? ""
      self.tags = medal.tags
      self.draftEventPhotos = medal.eventPhotos
        .sorted { $0.sortOrder < $1.sortOrder }
        .map { DraftEventPhoto(data: $0.imageData) }
    }
  }
  
  var isFormValid: Bool {
    let customDistanceValid: Bool = {
      if case .custom(let value) = distance.category { return value > 0 }
      return true
    }()
    
    return customDistanceValid &&
    !name.trimmingCharacters(in: .whitespaces).isEmpty &&
    !country.trimmingCharacters(in: .whitespaces).isEmpty &&
    !city.trimmingCharacters(in: .whitespaces).isEmpty
  }
  
  // MARK: - Functions
  
  func configure(context: ModelContext) {
    repository.configure(context: context)
  }
  
  func updatePhoto(with data: Data?) {
    self.photoData = data
    self.photo = data.flatMap { UIImage(data: $0) }
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
  
  func addEventPhotos(_ dataList: [Data]) {
    draftEventPhotos.append(contentsOf: dataList.map { DraftEventPhoto(data: $0) })
  }
  
  func removeEventPhoto(id: UUID) {
    draftEventPhotos.removeAll { $0.id == id }
  }
  
  func autoFill(from selection: RaceEntry) {
    name = "\(selection.race.name) \(selection.edition.year)"
    date = selection.edition.startDate
    distance = selection.distance
    country = selection.race.country
    province = selection.race.province ?? ""
    city = selection.race.city
    district = selection.race.district ?? ""
  }
  
  func save(by user: User) throws {
    if let medal, mode == .edit {
      medal.name = name
      medal.date = date
      medal.bibNumber = bibNumber
      medal.photoData = photoData
      medal.cropPhotoData = cropPhotoData
      medal.country = country
      medal.province = province.isEmpty ? nil : province
      medal.city = city
      medal.district = district.isEmpty ? nil : district
      medal.raceDistance = distance.category.value
      medal.raceDistanceType = distance.type.rawValue
      medal.finishTime = finishTime
      medal.overallPlacement = overallPlacement
      medal.totalParticipants = totalParticipants
      medal.division = division?.rawValue
      medal.divisionPlacement = divisionPlacement
      medal.divisionTotal = divisionTotal
      medal.genderPlacement = genderPlacement
      medal.genderTotal = genderTotal
      medal.note = note.isEmpty ? nil : note
      medal.tags = tags
      
      for photo in medal.eventPhotos {
        try repository.deleteEventPhoto(photo)
      }
      
      for (index, draft) in draftEventPhotos.enumerated() {
        try repository.insertEventPhoto(EventPhoto(imageData: draft.data, sortOrder: index, medal: medal))
      }
    } else {
      let newMedal = Medal(
        name: name,
        date: date,
        bibNumber: bibNumber,
        photoData: photoData,
        cropPhotoData: cropPhotoData,
        location: RaceLocation(
          country: country,
          province: province.isEmpty ? nil : province,
          city: city,
          district: district.isEmpty ? nil : district
        ),
        raceDistance: distance,
        finishTime: finishTime,
        overallPlacement: overallPlacement,
        totalParticipants: totalParticipants,
        division: division,
        divisionPlacement: divisionPlacement,
        divisionTotal: divisionTotal,
        genderPlacement: genderPlacement,
        genderTotal: genderTotal,
        note: note.isEmpty ? nil : note,
        tags: tags,
        user: user
      )
      
      try repository.insertMedal(newMedal)
      
      for (index, draft) in draftEventPhotos.enumerated() {
        try repository.insertEventPhoto(EventPhoto(imageData: draft.data, sortOrder: index, medal: newMedal))
      }
    }
    
    try repository.save()
  }
}
