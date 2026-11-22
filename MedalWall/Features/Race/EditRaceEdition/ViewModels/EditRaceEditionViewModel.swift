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
  /// The edition photo as its slot shows it and as save stages it.
  var photo = DraftPhoto()
  var distances: [RaceEvent] = []

  // MARK: - Dependencies
  let mode: ItemEditMode
  /// The staged edition being re-edited, carrying changes the race save hasn't written yet.
  private let draft: DraftRaceEdition?

  // MARK: - Init
  init(mode: ItemEditMode, draft: DraftRaceEdition?) {
    self.mode = mode
    self.draft = draft

    if let draft, mode == .edit {
      self.year = draft.year
      self.isOneDay = draft.isOneDay
      self.startDate = draft.startDate
      self.endDate = draft.endDate
      self.distances = draft.distances
      self.photo = DraftPhoto(storedPhotoUrl: draft.displayPhotoUrl, staged: draft.newPhoto)
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
    draft?.year ?? year
  }

  // MARK: - Functions
  /// Downloads the stored edition photo into `photo` so the slot shows the current image,
  /// marking it as failed when it can't be downloaded.
  func loadStoredPhoto() async {
    guard let photoUrl = draft?.displayPhotoUrl else { return }

    let storedPhoto = await UIImage.load(from: photoUrl)
    photo.showStored(storedPhoto)
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

  /// Appends a distance to the list, throwing if a custom value is not a usable distance or if it is already present.
  func addDistance(_ distance: RaceEvent) throws {
    guard distance.category.isValid else { throw AppError.invalidDistance }
    guard !distances.contains(distance) else { throw AppError.duplicateDistance }
    distances.append(distance)
  }

  /// Removes a distance from the list.
  func removeDistance(_ distance: RaceEvent) {
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
      draft.newPhoto = photo.croppedPhoto
      return draft

    case .edit:
      guard var updated = draft else {
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
      if photo.isChanged {
        if let croppedPhoto = photo.croppedPhoto {
          updated.newPhoto = croppedPhoto
          updated.isPhotoRemoved = false
        } else {
          updated.newPhoto = nil
          updated.isPhotoRemoved = true
        }
      }
      return updated
    }
  }
}
