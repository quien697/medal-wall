//
//  EditRaceViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-11-02.
//

import SwiftUI

@Observable
final class EditRaceViewModel {
  // MARK: - Data
  var name: String = ""
  var photo: UIImage?
  var place = Place(countryCode: "", city: "")
  var websiteUrl: String = ""

  // MARK: - State
  var isLoading = false
  var isEditionsLoading = false
  var error: AppError?
  private(set) var isPhotoChanged = false

  // MARK: - Edition Staging
  private var originalEditions: [RaceEdition] = []
  private var draftEditions: [DraftRaceEdition] = []
  private var editionIdsToDelete: Set<String> = []
  private var originalEditionIds: Set<String> = []

  // MARK: - Dependencies
  let mode: ItemEditMode
  private let race: Race?
  private let repository: any RaceRepository
  private let storageService: any PhotoStorage

  // MARK: - Init
  init(
    mode: ItemEditMode,
    race: Race?,
    repository: (any RaceRepository)? = nil,
    storageService: (any PhotoStorage)? = nil
  ) {
    self.mode = mode
    self.race = race
    self.repository = repository ?? RaceFirestoreRepository()
    self.storageService = storageService ?? StorageService()

    if let race, mode == .edit {
      self.name = race.name
      self.place = race.place
      self.websiteUrl = race.websiteUrl ?? ""
    }
  }

  // MARK: - Computed
  var raceId: String? { race?.id }

  var displayedEditions: [DraftRaceEdition] {
    draftEditions
      .filter { !editionIdsToDelete.contains($0.id) }
      .sorted { $0.startDate > $1.startDate }
  }

  var isFormValid: Bool {
    !name.trimmingCharacters(in: .whitespaces).isEmpty && place.isValid
  }

  // MARK: - Functions
  /// Loads editions from Firestore into the draft state, keeping any new edition staged
  /// before the load finished.
  func loadEditions() async {
    guard let raceId else { return }
    isEditionsLoading = true
    defer { isEditionsLoading = false }

    do {
      let loaded = try await repository.fetchEditions(raceId: raceId)
      originalEditions = loaded
      originalEditionIds = Set(loaded.map { $0.id })
      draftEditions =
        loaded.map { DraftRaceEdition(from: $0) }
        + draftEditions.filter { $0.sourceEditionId == nil }
    } catch {
      self.error = .raceFetchFailed(error.localizedDescription)
    }
  }

  /// Stages a new edition to be created on save.
  func stageAddEdition(_ draft: DraftRaceEdition) {
    draftEditions.append(draft)
  }

  /// Replaces a staged edition with an updated draft.
  func stageUpdateEdition(_ draft: DraftRaceEdition) {
    if let index = draftEditions.firstIndex(where: { $0.id == draft.id }) {
      draftEditions[index] = draft
    }
  }

  /// Marks an existing edition for deletion on save, or removes a new (unsaved) edition immediately.
  func stageDeleteEdition(id: String) {
    if originalEditionIds.contains(id) {
      editionIdsToDelete.insert(id)
    } else {
      draftEditions.removeAll { $0.id == id }
    }
  }

  /// Downloads the existing race photo into `photo` so the picker shows the current image.
  func loadExistingPhoto() async {
    let existingPhoto = await UIImage.load(from: race?.photoUrl)
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

  /// Creates or updates the race in Firestore, uploading the logo only when the photo was changed.
  func save(by userID: String) async {
    isLoading = true
    defer { isLoading = false }

    switch mode {
    case .add:
      do {
        var newRace = Race(
          name: name,
          place: place,
          websiteUrl: websiteUrl.isEmpty ? nil : websiteUrl,
          createdBy: userID
        )
        if let photo {
          newRace.photoUrl = try await storageService.uploadRaceLogo(
            raceId: newRace.id, image: photo)
        }
        try await repository.createRace(newRace)
      } catch {
        self.error = .raceSaveFailed
      }

    case .edit:
      guard var race else { return }
      race.name = name
      race.place = place
      race.websiteUrl = websiteUrl.isEmpty ? nil : websiteUrl
      if isPhotoChanged {
        if let photo {
          do {
            race.photoUrl = try await storageService.uploadRaceLogo(raceId: race.id, image: photo)
          } catch {
            self.error = .raceSaveFailed
            return
          }
        } else {
          try? await storageService.deleteRaceLogo(raceId: race.id)
          race.photoUrl = nil
        }
      }
      do {
        try await repository.updateRace(race)
      } catch {
        self.error = .raceSaveFailed
        return
      }
      await commitPendingEditions(raceId: race.id)
    }
  }

  /// Writes all pending edition creates, updates, and deletes to Firestore.
  ///
  /// Each delete and create that succeeds is recorded in the staged state, so saving again
  /// after a partial failure retries only what failed: repeating one would move the race's
  /// edition count a second time. A failed create or update is reported over a failed delete.
  private func commitPendingEditions(raceId: String) async {
    var anyDeleteFailed = false
    var anySaveFailed = false

    // Deletes
    for id in editionIdsToDelete where originalEditionIds.contains(id) {
      if let original = originalEditions.first(where: { $0.id == id }), original.photoUrl != nil {
        try? await storageService.deleteRaceEditionLogo(raceId: raceId, editionId: id)
      }

      do {
        try await repository.deleteEdition(raceId: raceId, editionId: id)
        originalEditionIds.remove(id)
      } catch {
        anyDeleteFailed = true
      }
    }

    // Creates
    for draft in draftEditions where draft.sourceEditionId == nil {
      var newEdition = RaceEdition(
        id: draft.id,
        raceId: raceId,
        year: draft.year,
        startDate: draft.startDate,
        endDate: draft.endDate,
        distances: draft.distances,
        createdBy: draft.createdBy
      )

      do {
        newEdition.photoUrl = try await uploadNewPhoto(of: draft, raceId: raceId)
        try await repository.createEdition(newEdition)
        originalEditions.append(newEdition)
        originalEditionIds.insert(newEdition.id)
        if let index = draftEditions.firstIndex(where: { $0.id == newEdition.id }) {
          draftEditions[index] = DraftRaceEdition(from: newEdition)
        }
      } catch {
        anySaveFailed = true
      }
    }

    // Updates
    for draft in draftEditions
    where draft.sourceEditionId != nil && draft.isModified && !editionIdsToDelete.contains(draft.id)
    {
      guard var edition = originalEditions.first(where: { $0.id == draft.id }) else { continue }

      edition.year = draft.year
      edition.startDate = draft.startDate
      edition.endDate = draft.endDate
      edition.distances = draft.distances

      do {
        if let photoUrl = try await uploadNewPhoto(of: draft, raceId: raceId) {
          edition.photoUrl = photoUrl
        } else if draft.isPhotoCleared {
          if edition.photoUrl != nil {
            try? await storageService.deleteRaceEditionLogo(raceId: raceId, editionId: edition.id)
          }
          edition.photoUrl = nil
        }
        try await repository.updateEdition(edition)
      } catch {
        anySaveFailed = true
      }
    }

    if anySaveFailed {
      error = .editionSaveFailed
    } else if anyDeleteFailed {
      error = .editionDeleteFailed
    }
  }

  /// Uploads the photo newly picked for a draft and returns its URL, or `nil` when it has none.
  private func uploadNewPhoto(of draft: DraftRaceEdition, raceId: String) async throws -> String? {
    guard let photoData = draft.newPhotoData, let photo = UIImage(data: photoData) else {
      return nil
    }

    return try await storageService.uploadRaceEditionLogo(
      raceId: raceId, editionId: draft.id, image: photo)
  }
}
