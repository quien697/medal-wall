//
//  EditRaceViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-11-02.
//

import SwiftUI

@Observable
final class EditRaceViewModel {
  // MARK: - Properties
  var name: String = ""
  var photo: UIImage? = nil
  var country: String = ""
  var province: String = ""
  var city: String = ""
  var district: String = ""
  var websiteUrl: String = ""
  var isLoading = false
  var error: AppError?
  private(set) var isPhotoChanged = false
  
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
  var isFormValid: Bool {
    !name.trimmingCharacters(in: .whitespaces).isEmpty &&
    !country.trimmingCharacters(in: .whitespaces).isEmpty &&
    !city.trimmingCharacters(in: .whitespaces).isEmpty
  }
  
  // MARK: - Functions
  
  /// Downloads the existing race photo into `photo` so the picker shows the current image.
  func loadExistingPhoto() async {
    photo = await UIImage.load(from: race?.photoUrl)
  }
  
  func updatePhoto(with uiImage: UIImage) {
    photo = uiImage
    isPhotoChanged = true
  }
  
  func clearPhoto() {
    photo = nil
    isPhotoChanged = true
  }
  
  /// Creates or updates the race in Firestore, uploading the logo only when the photo was changed.
  func save(by userID: String) async {
    isLoading = true
    defer { isLoading = false }
    
    do {
      switch mode {
      case .add:
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
            race.photoUrl = try await storageService.uploadRaceLogo(raceId: race.id, image: photo)
          } else {
            try? await storageService.deleteRaceLogo(raceId: race.id)
            race.photoUrl = nil
          }
        }
        try await repository.updateRace(race)
      }
    } catch {
      self.error = .raceSaveFailed
    }
  }
}
