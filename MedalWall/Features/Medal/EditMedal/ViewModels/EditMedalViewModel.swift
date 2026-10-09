//
//  EditMedalViewModel.swift
//  MedalWall
//

import SwiftUI

@Observable
final class EditMedalViewModel {
  // MARK: - Data
  var name: String = ""
  var date: Date = .now
  var bibNumber: String = ""
  var photo: UIImage?
  var place = Place(countryCode: "", city: "")
  var distance: RaceDistance = .default
  var finishTime: TimeInterval?
  var overallPlacement: Int?
  var totalParticipants: Int?
  var division: Division?
  var divisionPlacement: Int?
  var divisionTotal: Int?
  var genderPlacement: Int?
  var genderTotal: Int?
  var note: String = ""
  var tags: [String] = []
  var draftEventPhotos: [DraftEventPhoto] = []

  // MARK: - State
  var isLoading = false
  var error: AppError?
  private(set) var isPhotoChanged = false

  // MARK: - Dependencies
  let mode: ItemEditMode
  private let medal: Medal?
  private let medalId: String
  private let repository: any MedalRepository
  private let storageService: any PhotoStorage

  // MARK: - Init
  init(
    mode: ItemEditMode,
    medal: Medal? = nil,
    repository: (any MedalRepository)? = nil,
    storageService: (any PhotoStorage)? = nil
  ) {
    self.mode = mode
    self.medal = medal
    self.medalId = medal?.id ?? UUID().uuidString
    self.repository = repository ?? MedalFirestoreRepository()
    self.storageService = storageService ?? StorageService()

    if let medal, mode == .edit {
      self.name = medal.name
      self.date = medal.date
      self.bibNumber = medal.bibNumber
      self.place = medal.place
      self.distance = medal.distance
      self.finishTime = medal.finishTime
      self.overallPlacement = medal.overallPlacement
      self.totalParticipants = medal.totalParticipants
      self.division = medal.parsedDivision
      self.divisionPlacement = medal.divisionPlacement
      self.divisionTotal = medal.divisionTotal
      self.genderPlacement = medal.genderPlacement
      self.genderTotal = medal.genderTotal
      self.note = medal.note ?? ""
      self.tags = medal.tags
      self.draftEventPhotos = medal.eventPhotos
        .sorted { $0.sortOrder < $1.sortOrder }
        .map { DraftEventPhoto(id: $0.id, imageUrl: $0.imageUrl) }
    }
  }

  // MARK: - Computed
  var isFormValid: Bool {
    let customDistanceValid: Bool = {
      if case .custom(let value) = distance.category { return value > 0 }
      return true
    }()

    return customDistanceValid && !name.trimmingCharacters(in: .whitespaces).isEmpty
      && place.isValid
  }

  // MARK: - Functions
  /// Downloads the existing medal cover photo so the edit form can display it.
  func loadPhoto() async {
    let existingPhoto = await UIImage.load(from: medal?.photoUrl)
    guard !isPhotoChanged else { return }

    photo = existingPhoto
  }

  /// Sets the newly selected cover photo and marks it as changed.
  func updatePhoto(with uiImage: UIImage) {
    self.photo = uiImage
    isPhotoChanged = true
  }

  /// Clears the cover photo and marks it as changed.
  func clearPhoto() {
    self.photo = nil
    isPhotoChanged = true
  }

  /// Appends new event photos from the photo picker.
  func addEventPhotos(_ dataList: [Data]) {
    draftEventPhotos.append(contentsOf: dataList.map { DraftEventPhoto(data: $0) })
  }

  /// Removes an event photo draft by id.
  func removeEventPhoto(id: String) {
    draftEventPhotos.removeAll { $0.id == id }
  }

  /// Adds a tag trimmed of surrounding spaces, ignoring one that is blank or already there.
  func addTag(_ input: String) {
    let tag = input.trimmingCharacters(in: .whitespaces)
    guard !tag.isEmpty, !tags.contains(tag) else { return }

    tags.append(tag)
  }

  /// Removes a tag.
  func removeTag(_ tag: String) {
    tags.removeAll { $0 == tag }
  }

  /// Auto-fills form fields from a selected race entry.
  func autoFill(from selection: RaceEntry) {
    name = "\(selection.race.name) \(selection.edition.year)"
    date = selection.edition.startDate
    distance = selection.distance
    place = selection.race.place
  }

  /// Saves the medal to Firestore, uploading any new photos to Firebase Storage first.
  /// A removed cover or event photo is deleted from Storage only after the medal saves, so a
  /// failed save never points at a deleted file.
  func save(by userID: String) async throws {
    isLoading = true
    defer { isLoading = false }

    let photoUrl = try await resolvedPhotoUrl(userId: userID)
    let eventPhotos = try await resolvedEventPhotos(userId: userID)

    if let medal, mode == .edit {
      var updated = medal
      updated.name = name
      updated.date = date
      updated.bibNumber = bibNumber
      updated.photoUrl = photoUrl
      updated.place = place
      updated.distance = distance
      updated.finishTime = finishTime
      updated.overallPlacement = overallPlacement
      updated.totalParticipants = totalParticipants
      updated.division = division?.rawValue
      updated.divisionPlacement = divisionPlacement
      updated.divisionTotal = divisionTotal
      updated.genderPlacement = genderPlacement
      updated.genderTotal = genderTotal
      updated.note = note.isEmpty ? nil : note
      updated.tags = tags
      updated.eventPhotos = eventPhotos
      try await repository.updateMedal(updated)
      if isPhotoChanged, photo == nil, medal.photoUrl != nil {
        try? await storageService.deleteMedalPhoto(userId: userID, medalId: medalId)
      }
      let keptEventPhotoIDs = Set(eventPhotos.map(\.id))
      for removed in medal.eventPhotos where !keptEventPhotoIDs.contains(removed.id) {
        try? await storageService.deleteMedalEventPhoto(
          userId: userID, medalId: medalId, photoId: removed.id)
      }
    } else {
      let newMedal = Medal(
        id: medalId,
        name: name,
        date: date,
        bibNumber: bibNumber,
        photoUrl: photoUrl,
        place: place,
        distance: distance,
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
        eventPhotos: eventPhotos,
        userID: userID
      )
      try await repository.createMedal(newMedal)
    }
  }

  /// Returns the final cover photo URL: the existing one while the photo is unchanged, an
  /// upload of a newly picked one, or `nil` for a removed one. A removed photo is deleted from
  /// Storage only after the medal saves, so a failed save never points at a deleted file.
  private func resolvedPhotoUrl(userId: String) async throws -> String? {
    guard isPhotoChanged else { return medal?.photoUrl }
    guard let photo else { return nil }

    return try await storageService.uploadMedalPhoto(
      userId: userId, medalId: medalId, image: photo
    )
  }

  /// Uploads any new event photo drafts to Firebase Storage and returns the final EventPhoto array with stable sort order.
  private func resolvedEventPhotos(userId: String) async throws -> [EventPhoto] {
    var result: [EventPhoto] = []
    for (index, draft) in draftEventPhotos.enumerated() {
      if draft.isNew, let image = draft.image {
        let url = try await storageService.uploadMedalEventPhoto(
          userId: userId, medalId: medalId, photoId: draft.id, image: image)
        result.append(EventPhoto(id: draft.id, imageUrl: url, sortOrder: index))
      } else if let url = draft.imageUrl {
        result.append(EventPhoto(id: draft.id, imageUrl: url, sortOrder: index))
      }
    }
    return result
  }
}
