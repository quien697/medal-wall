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

  // MARK: - Dependencies
  let mode: ItemEditMode
  private let medal: Medal?
  private let medalId: String
  private let repository = MedalFirestoreRepository()
  private let storageService = StorageService()

  // MARK: - Init
  init(mode: ItemEditMode, medal: Medal? = nil) {
    self.mode = mode
    self.medal = medal
    self.medalId = medal?.id ?? UUID().uuidString

    if let medal, mode == .edit {
      self.name = medal.name
      self.date = medal.date
      self.bibNumber = medal.bibNumber
      self.place = medal.place
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
    photo = await UIImage.load(from: medal?.photoUrl)
  }

  /// Sets the newly selected cover photo.
  func updatePhoto(with uiImage: UIImage) {
    self.photo = uiImage
  }

  /// Clears the cover photo.
  func clearPhoto() {
    self.photo = nil
  }

  /// Appends new event photos from the photo picker.
  func addEventPhotos(_ dataList: [Data]) {
    draftEventPhotos.append(contentsOf: dataList.map { DraftEventPhoto(data: $0) })
  }

  /// Removes an event photo draft by id.
  func removeEventPhoto(id: String) {
    draftEventPhotos.removeAll { $0.id == id }
  }

  /// Auto-fills form fields from a selected race entry.
  func autoFill(from selection: RaceEntry) {
    name = "\(selection.race.name) \(selection.edition.year)"
    date = selection.edition.startDate
    distance = selection.distance
    place = selection.race.place
  }

  /// Saves the medal to Firestore, uploading any new photos to Firebase Storage first,
  /// then ratchets the user's achievement milestones based on the updated medal list.
  func save(by userID: String, userManager: UserManager) async throws {
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

    do {
      let medals = try await repository.fetchMedals(userId: userID)
      await userManager.refreshAchievementMilestones(medals: medals)
    } catch {}
  }

  /// Returns the final cover photo URL — uploads a new image if one was selected, otherwise reuses the existing URL.
  private func resolvedPhotoUrl(userId: String) async throws -> String? {
    guard let photo else { return medal?.photoUrl }
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
