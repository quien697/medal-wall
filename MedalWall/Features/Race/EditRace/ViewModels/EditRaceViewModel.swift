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
  var photo: UIImage? = nil
  var country: String = ""
  var province: String = ""
  var city: String = ""
  var district: String = ""
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
  private let repository = RaceFirestoreRepository()
  private let storageService = StorageService()
  
  // MARK: - Init
  init(mode: ItemEditMode, race: Race?) {
    self.mode = mode
    self.race = race
    
    if let race, mode == .edit {
      self.name = race.name
      self.country = race.location.country
      self.province = race.location.province ?? ""
      self.city = race.location.city
      self.district = race.location.district ?? ""
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
    !name.trimmingCharacters(in: .whitespaces).isEmpty &&
    !country.trimmingCharacters(in: .whitespaces).isEmpty &&
    !city.trimmingCharacters(in: .whitespaces).isEmpty
  }
  
  // MARK: - Functions
  /// Loads editions from Firestore into the draft state.
  func loadEditions() async {
    guard let raceId else { return }
    isEditionsLoading = true
    defer { isEditionsLoading = false }
    
    let loaded = (try? await repository.fetchEditions(raceId: raceId)) ?? []
    originalEditions = loaded
    originalEditionIds = Set(loaded.map { $0.id })
    draftEditions = loaded.map { DraftRaceEdition(from: $0) }
  }
  
  /// Stages a new edition to be created on save.
  func stageAddEdition(_ draft: DraftRaceEdition) {
    draftEditions.append(draft)
  }
  
  /// Replaces a staged edition with an updated draft.
  func stageUpdateEdition(_ draft: DraftRaceEdition) {
    if let idx = draftEditions.firstIndex(where: { $0.id == draft.id }) {
      draftEditions[idx] = draft
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
    photo = await UIImage.load(from: race?.photoUrl)
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
          location: GeoLocation(
            country: country,
            province: province.isEmpty ? nil : province,
            city: city,
            district: district.isEmpty ? nil : district
          ),
          websiteUrl: websiteUrl.isEmpty ? nil : websiteUrl,
          createdBy: userID
        )
        if let photo {
          newRace.photoUrl = try await storageService.uploadRaceLogo(raceId: newRace.id, image: photo)
        }
        try await repository.createRace(newRace)
      } catch {
        self.error = .raceSaveFailed
      }
      
    case .edit:
      guard var race else { return }
      race.name = name
      race.location = GeoLocation(
        country: country,
        province: province.isEmpty ? nil : province,
        city: city,
        district: district.isEmpty ? nil : district
      )
      race.websiteUrl = websiteUrl.isEmpty ? nil : websiteUrl
      if isPhotoChanged {
        if let photo {
          race.photoUrl = try? await storageService.uploadRaceLogo(raceId: race.id, image: photo)
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
  private func commitPendingEditions(raceId: String) async {
    var anyFailed = false
    
    // Deletes
    for id in editionIdsToDelete where originalEditionIds.contains(id) {
      if let original = originalEditions.first(where: { $0.id == id }), original.photoUrl != nil {
        try? await storageService.deleteRaceEditionLogo(raceId: raceId, editionId: id)
      }
      
      do {
        try await repository.deleteEdition(raceId: raceId, editionId: id)
      } catch {
        anyFailed = true
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
      
      if let photoData = draft.newPhotoData, let photo = UIImage(data: photoData) {
        newEdition.photoUrl = try? await storageService.uploadRaceEditionLogo(
          raceId: raceId, editionId: newEdition.id, image: photo
        )
      }
      
      do {
        try await repository.createEdition(newEdition)
      } catch {
        anyFailed = true
      }
    }
    
    // Updates
    for draft in draftEditions where draft.sourceEditionId != nil && draft.isModified && !editionIdsToDelete.contains(draft.id) {
      guard var edition = originalEditions.first(where: { $0.id == draft.id }) else { continue }
      
      edition.year = draft.year
      edition.startDate = draft.startDate
      edition.endDate = draft.endDate
      edition.distances = draft.distances
      
      if let photoData = draft.newPhotoData, let photo = UIImage(data: photoData) {
        edition.photoUrl = try? await storageService.uploadRaceEditionLogo(
          raceId: raceId, editionId: edition.id, image: photo
        )
      } else if draft.isPhotoCleared {
        if edition.photoUrl != nil {
          try? await storageService.deleteRaceEditionLogo(raceId: raceId, editionId: edition.id)
        }
        edition.photoUrl = nil
      }
      
      do {
        try await repository.updateEdition(edition)
      } catch {
        anyFailed = true
      }
    }
    
    if anyFailed { error = .editionSaveFailed }
  }
}
