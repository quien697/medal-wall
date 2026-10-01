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
  /// The staged edition being re-edited, carrying changes the race save hasn't written yet.
  private let draft: DraftRaceEdition?
  private let repository: any RaceRepository
  private let storageService: any PhotoStorage

  // MARK: - Init
  init(
    mode: ItemEditMode,
    raceId: String,
    edition: RaceEdition?,
    draft: DraftRaceEdition? = nil,
    repository: (any RaceRepository)? = nil,
    storageService: (any PhotoStorage)? = nil
  ) {
    self.mode = mode
    self.raceId = raceId
    self.edition = edition
    self.draft = draft
    self.repository = repository ?? RaceFirestoreRepository()
    self.storageService = storageService ?? StorageService()

    if let draft, mode == .edit {
      self.year = draft.year
      self.isOneDay = draft.isOneDay
      self.startDate = draft.startDate
      self.endDate = draft.endDate
      self.distances = draft.distances
      self.photo = draft.displayPhoto
    } else if let edition, mode == .edit {
      self.year = edition.year
      self.isOneDay = edition.isOneDay
      self.startDate = edition.startDate
      self.endDate = edition.endDate
      self.distances = edition.distances
    } else {
      let currentYear = Date.now.year
      self.year = currentYear
      self.isOneDay = true
      let startOfYear = Date.startOfYear(currentYear)
      self.startDate = startOfYear
      self.endDate = startOfYear
      self.distances = []
    }
  }

  // MARK: - Computed
  var photoHint: String {
    photo == nil
      ? .appLocalized("Tap to add a new edition photo,\nor leave empty to use the race logo.")
      : .appLocalized("Tap to update the edition photo,\nor leave empty to use the race logo.")
  }

  var isFormValid: Bool {
    year >= minYear && year <= maxYear && startDate <= endDate
  }

  var yearDateRange: ClosedRange<Date> {
    Date.yearRange(year)
  }

  var minEndDate: Date { startDate }

  var maxEndDate: Date {
    Date.endOfYear(year)
  }

  /// The year the edition had when the form opened — what a delete removes, whatever `year`
  /// has since been edited to.
  var originalYear: Int {
    draft?.year ?? edition?.year ?? year
  }

  // MARK: - Functions
  /// Downloads the existing edition photo into `photo` so the picker shows the current image.
  func loadExistingPhoto() async {
    let photoUrl = if let draft { draft.displayPhotoUrl } else { edition?.photoUrl }
    guard let photoUrl else { return }

    let existingPhoto = await UIImage.load(from: photoUrl)
    guard !isPhotoChanged else { return }

    photo = existingPhoto
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
    let startOfYear = Date.startOfYear(newYear)
    let endOfYear = Date.endOfYear(newYear)
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
      if let photo, let data = photo.uploadData() {
        draft.newPhotoData = data
      }
      return draft

    case .edit:
      guard var updated = draft ?? edition.map({ DraftRaceEdition(from: $0) }) else {
        return DraftRaceEdition(
          year: year, isOneDay: isOneDay, startDate: startDate,
          endDate: endDate, distances: distances, createdBy: userId
        )
      }
      updated.year = year
      updated.isOneDay = isOneDay
      updated.startDate = startDate
      updated.endDate = endDate
      updated.distances = distances
      updated.isModified = true
      if isPhotoChanged {
        if let photo, let data = photo.uploadData() {
          updated.newPhotoData = data
          updated.isPhotoCleared = false
        } else {
          updated.newPhotoData = nil
          updated.isPhotoCleared = true
        }
      }
      return updated
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
