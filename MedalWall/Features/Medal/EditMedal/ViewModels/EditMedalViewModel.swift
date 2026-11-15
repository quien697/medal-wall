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
  /// The front as the form shows it: the stored photo once loaded, or a staged framed photo.
  private(set) var frontPhoto: UIImage?
  /// The back as the form shows it: the stored photo once loaded, or a staged framed photo.
  private(set) var backPhoto: UIImage?
  var place = Place(countryCode: "", city: "")
  var distance: RaceEvent = .default
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
  /// The faces the user replaced or removed; the others keep their stored URLs on save.
  private(set) var changedFaces: Set<MedalFace> = []
  /// Each stored face the form is not showing: still downloading, or one that couldn't be.
  private var storedPhotoStatuses: [MedalFace: StoredPhotoStatus] = [:]

  // MARK: - Dependencies
  let mode: ItemEditMode
  private let medal: Medal?
  private let medalId: String
  private let repository: any MedalRepository
  private let storageService: any PhotoStorage
  private let networkMonitor: any NetworkMonitor

  // MARK: - Init
  init(
    mode: ItemEditMode,
    medal: Medal? = nil,
    repository: (any MedalRepository)? = nil,
    storageService: (any PhotoStorage)? = nil,
    networkMonitor: (any NetworkMonitor)? = nil
  ) {
    self.mode = mode
    self.medal = medal
    self.medalId = medal?.id ?? UUID().uuidString
    self.repository = repository ?? MedalFirestoreRepository()
    self.storageService = storageService ?? StorageService()
    self.networkMonitor = networkMonitor ?? NWPathNetworkMonitor()

    if let medal, mode == .edit {
      self.name = medal.name
      self.date = medal.date
      self.bibNumber = medal.bibNumber
      self.place = medal.place
      self.distance = medal.raceEvent
      self.finishTime = medal.recordedFinishTime
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
      for face in MedalFace.allCases where medal.photoUrls?[face] != nil {
        self.storedPhotoStatuses[face] = .loading
      }
    }
  }

  // MARK: - Computed
  var isFormValid: Bool {
    let customDistanceValid: Bool = {
      if !distance.category.isStandard { return distance.category.isValidCustom }
      return true
    }()

    return customDistanceValid && !trimmedName.isEmpty && place.isValid
  }

  private var trimmedName: String { name.trimmingCharacters(in: .whitespacesAndNewlines) }

  private var trimmedBibNumber: String {
    bibNumber.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private var trimmedNote: String? {
    let trimmed = note.trimmingCharacters(in: .whitespacesAndNewlines)
    return trimmed.isEmpty ? nil : trimmed
  }

  // MARK: - Functions
  /// The photo the form shows for `face`.
  func photo(for face: MedalFace) -> UIImage? {
    switch face {
    case .front: frontPhoto
    case .back: backPhoto
    }
  }

  /// The status of `face`'s stored photo while the form isn't showing it, or `nil`.
  func storedPhotoStatus(for face: MedalFace) -> StoredPhotoStatus? {
    storedPhotoStatuses[face]
  }

  /// Downloads the medal's stored faces so the form can show them, marking a face that can't
  /// be downloaded as failed. A face the user changed while they downloaded keeps the change.
  func loadPhotos() async {
    async let loadedFront = UIImage.load(from: medal?.photoUrls?.front)
    async let loadedBack = UIImage.load(from: medal?.photoUrls?.back)
    let (front, back) = await (loadedFront, loadedBack)

    if !changedFaces.contains(.front) { frontPhoto = front }
    if !changedFaces.contains(.back) { backPhoto = back }

    for face in MedalFace.allCases where storedPhotoStatuses[face] == .loading {
      storedPhotoStatuses[face] = photo(for: face) == nil ? .failed : nil
    }
  }

  /// Stages a photo framed for `face`, leaving the other face as it is.
  func updatePhoto(with photo: UIImage, for face: MedalFace) {
    stage(photo, for: face)
  }

  /// Removes the photo of `face`, leaving the other face as it is.
  func clearPhoto(for face: MedalFace) {
    stage(nil, for: face)
  }

  /// Appends new event photos from the photo picker.
  func addEventPhotos(_ dataList: [Data]) {
    draftEventPhotos.append(contentsOf: dataList.map { DraftEventPhoto(data: $0) })
  }

  /// Removes an event photo draft by id.
  func removeEventPhoto(id: String) {
    draftEventPhotos.removeAll { $0.id == id }
  }

  /// Adds a tag trimmed of surrounding whitespace, ignoring one that is blank or already there.
  func addTag(_ input: String) {
    let tag = input.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !tag.isEmpty, !tags.contains(tag) else { return }

    tags.append(tag)
  }

  /// Removes a tag.
  func removeTag(_ tag: String) {
    tags.removeAll { $0 == tag }
  }

  /// Sets the medal's distance, throwing if a custom value is not a usable distance.
  func selectDistance(_ newDistance: RaceEvent) throws {
    if !newDistance.category.isStandard, !newDistance.category.isValidCustom {
      throw AppError.invalidDistance
    }
    distance = newDistance
  }

  /// Auto-fills form fields from a selected race entry.
  func autoFill(from selection: RaceEntry) {
    name = "\(selection.race.name) \(selection.edition.year)"
    date = selection.edition.startDate
    distance = selection.raceEvent
    place = selection.race.place
  }

  /// Saves the medal to Firestore, uploading any new photos to Firebase Storage first.
  /// A removed or replaced face, or a removed event photo, is deleted from Storage only
  /// after the medal saves, so a failed save never points at a deleted file. A failed save
  /// deletes the photos uploaded for it. Offline, it throws `AppError.noInternetConnection`
  /// before uploading or writing anything. Name, bib number and note are saved without
  /// surrounding whitespace, and a note of only whitespace is saved as none.
  func save(by userID: String) async throws {
    isLoading = true
    defer { isLoading = false }

    guard await networkMonitor.isConnected() else { throw AppError.noInternetConnection }

    let owner = PhotoOwner.medal(userId: userID, medalId: medalId)
    var uploadedUrls: [String] = []
    do {
      let frontUrl = try await resolvedPhotoUrl(
        for: .front, userId: userID, uploadedUrls: &uploadedUrls)
      let backUrl = try await resolvedPhotoUrl(
        for: .back, userId: userID, uploadedUrls: &uploadedUrls)
      let eventPhotos = try await resolvedEventPhotos(userId: userID, uploadedUrls: &uploadedUrls)
      let resolvedPhotoUrls = MedalPhotoUrls(front: frontUrl, back: backUrl)
      // A medal without photos stores no map rather than an empty one.
      let photoUrls = resolvedPhotoUrls.isEmpty ? nil : resolvedPhotoUrls

      if let medal, mode == .edit {
        var updated = medal
        updated.name = trimmedName
        updated.date = date
        updated.bibNumber = trimmedBibNumber
        updated.photoUrls = photoUrls
        updated.place = place
        updated.raceEvent = distance
        updated.result = finishTime.map(RaceResult.seconds)
        updated.overallPlacement = overallPlacement
        updated.totalParticipants = totalParticipants
        updated.division = division?.rawValue
        updated.divisionPlacement = divisionPlacement
        updated.divisionTotal = divisionTotal
        updated.genderPlacement = genderPlacement
        updated.genderTotal = genderTotal
        updated.note = trimmedNote
        updated.tags = tags
        updated.eventPhotos = eventPhotos
        try await repository.updateMedal(updated)
        await deletePhotos(of: medal, droppedBy: updated, ownedBy: owner)
      } else {
        let newMedal = Medal(
          id: medalId,
          name: trimmedName,
          date: date,
          bibNumber: trimmedBibNumber,
          photoUrls: photoUrls,
          place: place,
          raceEvent: distance,
          result: finishTime.map(RaceResult.seconds),
          overallPlacement: overallPlacement,
          totalParticipants: totalParticipants,
          division: division,
          divisionPlacement: divisionPlacement,
          divisionTotal: divisionTotal,
          genderPlacement: genderPlacement,
          genderTotal: genderTotal,
          note: trimmedNote,
          tags: tags,
          eventPhotos: eventPhotos,
          userID: userID
        )
        try await repository.createMedal(newMedal)
      }
    } catch {
      for url in uploadedUrls {
        try? await storageService.deletePhoto(url: url, ownedBy: owner)
      }
      throw error
    }
  }

  /// Deletes from Storage every photo `stored` held that `saved` no longer does: a replaced or
  /// removed face, and each removed event photo. Call only after `saved` is written, so a
  /// failed save never points at a deleted file; a photo that fails to delete is left behind.
  private func deletePhotos(of stored: Medal, droppedBy saved: Medal, ownedBy owner: PhotoOwner)
    async
  {
    for face in MedalFace.allCases {
      if let oldUrl = stored.photoUrls?[face], oldUrl != saved.photoUrls?[face] {
        try? await storageService.deletePhoto(url: oldUrl, ownedBy: owner)
      }
    }
    let keptEventPhotoIDs = Set(saved.eventPhotos.map(\.id))
    for removed in stored.eventPhotos where !keptEventPhotoIDs.contains(removed.id) {
      try? await storageService.deletePhoto(url: removed.imageUrl, ownedBy: owner)
    }
  }

  /// Stages `photo` for `face` and marks the face as changed.
  private func stage(_ photo: UIImage?, for face: MedalFace) {
    switch face {
    case .front: frontPhoto = photo
    case .back: backPhoto = photo
    }
    changedFaces.insert(face)
    storedPhotoStatuses[face] = nil
  }

  /// Returns the final URL of `face`: the stored one while the face is unchanged, an upload of
  /// a staged photo, or `nil` for a removed one. A removed face is deleted from Storage only
  /// after the medal saves, so a failed save never points at a deleted file.
  private func resolvedPhotoUrl(
    for face: MedalFace, userId: String, uploadedUrls: inout [String]
  ) async throws -> String? {
    guard changedFaces.contains(face) else { return medal?.photoUrls?[face] }
    guard let photo = photo(for: face) else { return nil }

    let url = try await storageService.uploadMedalFace(
      userId: userId, medalId: medalId, face: face, image: photo
    )
    uploadedUrls.append(url)
    return url
  }

  /// Uploads any new event photo drafts to Firebase Storage and returns the final EventPhoto array with stable sort order.
  /// A kept photo keeps every stored field but its order.
  private func resolvedEventPhotos(userId: String, uploadedUrls: inout [String]) async throws
    -> [EventPhoto]
  {
    var result: [EventPhoto] = []
    for (index, draft) in draftEventPhotos.enumerated() {
      if draft.isNew, let image = draft.image {
        let url = try await storageService.uploadMedalEventPhoto(
          userId: userId, medalId: medalId, photoId: draft.id, image: image)
        uploadedUrls.append(url)
        result.append(EventPhoto(id: draft.id, imageUrl: url, sortOrder: index))
      } else if var kept = medal?.eventPhotos.first(where: { $0.id == draft.id }) {
        kept.sortOrder = index
        result.append(kept)
      }
    }
    return result
  }
}
