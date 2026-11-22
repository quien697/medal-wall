//
//  EditMedalViewModel.swift
//  MedalWall
//

import PhotosUI
import SwiftUI

@Observable
final class EditMedalViewModel {
  // MARK: - Data
  var name: String = ""
  var date: Date = .now
  var bibNumber: String = ""
  /// Each face's photo as its slot shows it and as save uploads it.
  private var facePhotos = Dictionary(
    uniqueKeysWithValues: MedalFace.allCases.map { ($0, DraftPhoto()) })
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
  /// Whether picked event photos are still being loaded and checked, which Save waits for.
  private(set) var isCheckingEventPhotos = false
  var isLoading = false
  var error: AppError?

  // MARK: - Dependencies
  let mode: ItemEditMode
  private let medal: Medal?
  private let medalId: String
  private let repository: any MedalRepository
  private let storageService: any PhotoStorage
  private let networkMonitor: any NetworkMonitor
  /// Loads a photo picked in the photo library as its file's data, or nil if it can't be.
  private let loadPickedPhoto: (PhotosPickerItem) async -> Data?

  // MARK: - Init
  init(
    mode: ItemEditMode,
    medal: Medal? = nil,
    repository: (any MedalRepository)? = nil,
    storageService: (any PhotoStorage)? = nil,
    networkMonitor: (any NetworkMonitor)? = nil,
    loadPickedPhoto: ((PhotosPickerItem) async -> Data?)? = nil
  ) {
    self.mode = mode
    self.medal = medal
    self.medalId = medal?.id ?? UUID().uuidString
    self.repository = repository ?? MedalFirestoreRepository()
    self.storageService = storageService ?? StorageService()
    self.networkMonitor = networkMonitor ?? NWPathNetworkMonitor()
    self.loadPickedPhoto = loadPickedPhoto ?? { try? await $0.loadTransferable(type: Data.self) }

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
      for face in MedalFace.allCases {
        self.facePhotos[face] = DraftPhoto(storedPhotoUrl: medal.photoUrls?[face])
      }
    }
  }

  // MARK: - Computed
  /// Whether Save can be tapped: the form is valid and no event photo is still being checked.
  var canSave: Bool { isFormValid && !isCheckingEventPhotos }

  var isFormValid: Bool {
    distance.category.isValid && !trimmedName.isEmpty && place.isValid
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
  /// What the slot for `face` shows.
  func photoContent(for face: MedalFace) -> PhotoSlotContent {
    facePhotos[face]?.content ?? .empty
  }

  /// Downloads the medal's stored faces so the form can show them, marking a face that can't
  /// be downloaded as failed. A face the user changed while they downloaded keeps the change.
  func loadStoredPhotos() async {
    async let loadedFront = UIImage.load(from: medal?.photoUrls?.front)
    async let loadedBack = UIImage.load(from: medal?.photoUrls?.back)
    let (front, back) = await (loadedFront, loadedBack)

    facePhotos[.front]?.showStored(front)
    facePhotos[.back]?.showStored(back)
  }

  /// Stages a photo cropped for `face`, leaving the other face as it is.
  func updatePhoto(with photo: CroppedPhoto, for face: MedalFace) {
    facePhotos[face]?.update(with: photo)
  }

  /// Removes the photo of `face`, leaving the other face as it is.
  func removePhoto(for face: MedalFace) {
    facePhotos[face]?.remove()
  }

  /// Loads the event photos picked in the photo library and stages them as `addEventPhotos(_:)`
  /// does, holding Save from the start of loading to the end of the check.
  ///
  /// An item that can't be loaded is skipped and counts as not an image. Once the others are
  /// added, throws `.photoTooLarge` if any item was too large, and otherwise
  /// `.photoDataInvalid` if any was not an image.
  func addEventPhotos(from items: [PhotosPickerItem]) async throws(AppError) {
    isCheckingEventPhotos = true
    defer { isCheckingEventPhotos = false }

    var dataList: [Data] = []
    for item in items {
      if let data = await loadPickedPhoto(item) {
        dataList.append(data)
      }
    }
    try await addEventPhotos(dataList)
    if dataList.count < items.count { throw .photoDataInvalid }
  }

  /// Appends new event photos from the photo picker, each staged as its checked JPEG, which
  /// save uploads as it is.
  ///
  /// An item that is not an image, or whose JPEG Storage would refuse for its size, is skipped.
  /// Once the others are added, throws `.photoTooLarge` if any item was too large, and
  /// otherwise `.photoDataInvalid` if any was not an image.
  func addEventPhotos(_ dataList: [Data]) async throws(AppError) {
    let results = await Self.checkedJPEGs(of: dataList)
    for case .success(let jpegData) in results {
      draftEventPhotos.append(DraftEventPhoto(data: jpegData))
    }
    if results.contains(.failure(.photoTooLarge)) { throw .photoTooLarge }
    if results.contains(.failure(.photoDataInvalid)) { throw .photoDataInvalid }
  }

  /// Each picked item's checked JPEG, or the error it meets. Runs off the main actor, since
  /// encoding a full-resolution photo takes a noticeable moment.
  @concurrent
  nonisolated private static func checkedJPEGs(of dataList: [Data]) async -> [Result<
    Data, AppError
  >] {
    dataList.map { data in
      // Frees each photo's decoded and encoded buffers before the next, so ten large photos are
      // never in memory together.
      autoreleasepool { () -> Result<Data, AppError> in
        guard let image = UIImage(data: data) else { return .failure(.photoDataInvalid) }
        return Result { () throws(AppError) in try image.checkedUploadData() }
      }
    }
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
    guard newDistance.category.isValid else { throw AppError.invalidDistance }
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

  /// Returns the final URL of `face`: the stored one while the face is unchanged, an upload of
  /// a staged photo, or `nil` for a removed one. A removed face is deleted from Storage only
  /// after the medal saves, so a failed save never points at a deleted file.
  private func resolvedPhotoUrl(
    for face: MedalFace, userId: String, uploadedUrls: inout [String]
  ) async throws -> String? {
    guard let photo = facePhotos[face], photo.isChanged else { return medal?.photoUrls?[face] }
    guard let croppedPhoto = photo.croppedPhoto else { return nil }

    let url = try await storageService.uploadMedalFace(
      userId: userId, medalId: medalId, face: face, jpegData: croppedPhoto.jpegData
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
      if draft.isNew, let jpegData = draft.data {
        let url = try await storageService.uploadMedalEventPhoto(
          userId: userId, medalId: medalId, photoId: draft.id, jpegData: jpegData)
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
