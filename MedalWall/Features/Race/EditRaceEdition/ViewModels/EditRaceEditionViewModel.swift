//
//  EditRaceEditionViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-03-26.
//

import SwiftUI

@Observable
final class EditRaceEditionViewModel {
  // MARK: - Data
  var year: Int
  let minYear: Int = 1911
  let maxYear: Int = 2060
  var isOneDay: Bool
  var startDate: Date
  var endDate: Date
  var photo: UIImage?
  var distances: [RaceDistance] = []

  // MARK: - State
  var isPhotoChanged = false
  var isLoading = false
  var error: AppError?

  // MARK: - Dependencies
  let mode: ItemEditMode
  private let raceId: String
  private let edition: RaceEdition?
  private let repository = RaceFirestoreRepository()
  private let storageService = StorageService()

  // MARK: - Init
  init(mode: ItemEditMode, raceId: String, edition: RaceEdition?) {
    self.mode = mode
    self.raceId = raceId
    self.edition = edition

    if let edition, mode == .edit {
      self.year = edition.year
      self.isOneDay = edition.isOneDay
      self.startDate = edition.startDate
      self.endDate = edition.endDate
      self.distances = edition.distances
    } else {
      let currentYear = Calendar.current.component(.year, from: Date())
      self.year = currentYear
      self.isOneDay = true
      let startOfYear =
        Calendar.current.date(from: DateComponents(year: currentYear, month: 1, day: 1)) ?? Date()
      self.startDate = startOfYear
      self.endDate = startOfYear
      self.distances = []
    }
  }

  // MARK: - Computed
  var photoHint: String {
    let action = photo == nil ? "add a new" : "update the"
    return "Tap to \(action) edition photo,\nor leave empty to use the race logo."
  }

  var isFormValid: Bool {
    year >= minYear && year <= maxYear && startDate <= endDate
  }

  var yearDateRange: ClosedRange<Date> {
    let calendar = Calendar.current
    let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) ?? Date()
    let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31)) ?? Date()
    return startOfYear...endOfYear
  }

  var minEndDate: Date { startDate }

  var maxEndDate: Date {
    Calendar.current.date(from: DateComponents(year: year, month: 12, day: 31)) ?? Date()
  }

  // MARK: - Functions
  /// Downloads the existing edition photo into `photo` so the picker shows the current image.
  func loadExistingPhoto() async {
    photo = await UIImage.load(from: edition?.photoUrl)
  }

  /// Replaces the current photo and marks it as changed.
  func updatePhoto(with uiImage: UIImage) {
    photo = uiImage
    isPhotoChanged = true
  }

  /// Clears the current photo and marks it as changed.
  func clearPhoto() {
    photo = nil
    isPhotoChanged = true
  }

  /// Toggles the one-day flag and aligns the end date with start date when enabled.
  func toggleOneDay() {
    isOneDay.toggle()
    if isOneDay { endDate = startDate }
  }

  /// Updates the year and clamps both dates to remain within the new year's bounds.
  func updateYear(_ newYear: Int) {
    year = newYear
    let calendar = Calendar.current
    let startOfYear = calendar.date(from: DateComponents(year: newYear, month: 1, day: 1)) ?? Date()
    let endOfYear = calendar.date(from: DateComponents(year: newYear, month: 12, day: 31)) ?? Date()
    if startDate < startOfYear || startDate > endOfYear { startDate = startOfYear }
    if endDate < startDate || endDate > endOfYear { endDate = isOneDay ? startDate : endOfYear }
  }

  /// Updates the start date and advances the end date if it would fall before the new start.
  func updateStartDate(_ newStartDate: Date) {
    startDate = newStartDate
    if isOneDay {
      endDate = newStartDate
    } else if endDate < newStartDate {
      endDate = newStartDate
    }
  }

  /// Appends a distance to the list, throwing if the custom value is zero/negative or if it is already present.
  func addDistance(_ distance: RaceDistance) throws {
    if case .custom(let value) = distance.category, value <= 0 {
      throw AppError.invalidDistance
    }
    guard !distances.contains(distance) else { throw AppError.duplicateDistance }
    distances.append(distance)
  }

  /// Removes a distance from the list.
  func removeDistance(_ distance: RaceDistance) {
    distances.removeAll { $0 == distance }
  }

  /// Constructs a DraftRaceEdition from current form state without saving to Firestore.
  func buildDraft(userId: String) -> DraftRaceEdition {
    switch mode {
    case .add:
      var draft = DraftRaceEdition(
        year: year,
        isOneDay: isOneDay,
        startDate: startDate,
        endDate: endDate,
        distances: distances,
        createdBy: userId
      )
      if let photo, let data = photo.jpegData(compressionQuality: 0.8) {
        draft.newPhotoData = data
      }
      return draft

    case .edit:
      guard let edition else {
        return DraftRaceEdition(
          year: year, isOneDay: isOneDay, startDate: startDate,
          endDate: endDate, distances: distances, createdBy: userId
        )
      }
      var draft = DraftRaceEdition(from: edition)
      draft.year = year
      draft.isOneDay = isOneDay
      draft.startDate = startDate
      draft.endDate = endDate
      draft.distances = distances
      draft.isModified = true
      if isPhotoChanged {
        if let photo, let data = photo.jpegData(compressionQuality: 0.8) {
          draft.newPhotoData = data
          draft.isPhotoCleared = false
        } else {
          draft.newPhotoData = nil
          draft.isPhotoCleared = true
        }
      }
      return draft
    }
  }

  /// Creates or updates the edition in Firestore, uploading the photo only when it was changed.
  func save(by userID: String) async {
    isLoading = true
    defer { isLoading = false }

    do {
      switch mode {
      case .add:
        var newEdition = RaceEdition(
          raceId: raceId,
          year: year,
          startDate: startDate,
          endDate: endDate,
          distances: distances,
          createdBy: userID
        )
        if let photo {
          newEdition.photoUrl = try await storageService.uploadRaceEditionLogo(
            raceId: raceId, editionId: newEdition.id, image: photo
          )
        }
        try await repository.createEdition(newEdition)

      case .edit:
        guard var edition else { return }
        edition.year = year
        edition.startDate = startDate
        edition.endDate = endDate
        edition.distances = distances
        if isPhotoChanged {
          if let photo {
            edition.photoUrl = try await storageService.uploadRaceEditionLogo(
              raceId: raceId, editionId: edition.id, image: photo
            )
          } else {
            try? await storageService.deleteRaceEditionLogo(raceId: raceId, editionId: edition.id)
            edition.photoUrl = nil
          }
        }
        try await repository.updateEdition(edition)
      }
    } catch {
      self.error = .editionSaveFailed
    }
  }

  /// Deletes the edition from Firestore and cleans up its photo from Storage.
  func deleteEdition() async {
    guard let edition else { return }
    isLoading = true
    defer { isLoading = false }

    do {
      if edition.photoUrl != nil {
        try? await storageService.deleteRaceEditionLogo(raceId: raceId, editionId: edition.id)
      }
      try await repository.deleteEdition(raceId: raceId, editionId: edition.id)
    } catch {
      self.error = .editionDeleteFailed
    }
  }
}
