//
//  MedalDetailViewModel.swift
//  MedalWall
//
//  Created by Quien on 2025-12-24.
//

import SwiftUI

@MainActor
@Observable
final class MedalDetailViewModel {
  // MARK: - Data
  var medal: Medal
  /// The ids of medals that currently hold a record, taken from the whole collection.
  ///
  /// Stored as a `var` rather than a `let` so `isPersonalRecord` stays live: an edit
  /// elsewhere in the collection can demote or promote this medal between reloads, and
  /// the "PR" tag should follow the latest state without the user popping the screen.
  var personalRecordIDs: Set<String>
  private static let unfilled = "—"

  // MARK: - State
  /// Orders the reloads, so an older reload's medal and record marker never replace a newer
  /// reload's.
  private var reloads = LoadSequence()
  /// The face the details show, whether or not it has a photo: an empty face shows its
  /// placeholder.
  private(set) var faceInView: MedalFace = .front

  // MARK: - Dependencies
  private let repository: any MedalRepository
  private let storageService: any PhotoStorage
  private let networkMonitor: any NetworkMonitor

  // MARK: - Init
  init(
    medal: Medal,
    personalRecordIDs: Set<String> = [],
    repository: (any MedalRepository)? = nil,
    storageService: (any PhotoStorage)? = nil,
    networkMonitor: (any NetworkMonitor)? = nil
  ) {
    self.medal = medal
    self.personalRecordIDs = personalRecordIDs
    self.repository = repository ?? MedalFirestoreRepository()
    self.storageService = storageService ?? StorageService()
    self.networkMonitor = networkMonitor ?? NWPathNetworkMonitor()
  }

  // MARK: - Computed
  /// What tapping the medal does, for VoiceOver.
  var flipHint: LocalizedStringKey {
    switch faceInView {
    case .front: "Shows the back"
    case .back: "Shows the front"
    }
  }

  /// Whether this medal currently holds a record at its distance.
  var isPersonalRecord: Bool {
    personalRecordIDs.contains(medal.id)
  }

  /// The finish time, or the same wording the collection list uses for an untimed medal.
  var finishTimeText: String {
    guard let finishTime = medal.recordedFinishTime else {
      return .appLocalized("No time recorded")
    }
    return finishTime.formattedHMS
  }

  /// The pace without its unit, so the screen can set the two at different sizes.
  var averagePaceValue: String {
    let unit = DistanceUnit.resolved()
    return unit.paceValueText(minutesPerUnit: medal.averagePace(in: unit)) ?? Self.unfilled
  }

  /// The unit the pace is expressed in, absent when there is no pace to qualify.
  var averagePaceUnit: String? {
    let unit = DistanceUnit.resolved()
    guard unit.paceValueText(minutesPerUnit: medal.averagePace(in: unit)) != nil else { return nil }

    return "/\(unit.abbreviation())"
  }

  var overallPlacementText: String {
    Self.placementText(medal.overallPlacement)
  }

  var overallTotalText: String? {
    Self.totalText(medal.totalParticipants, placement: medal.overallPlacement)
  }

  /// The division field's label, naming the group the placement was run within so the two
  /// read as one fact rather than two measurements.
  var divisionLabel: String {
    guard let division = medal.parsedDivision else { return .appLocalized("Division") }
    return .appLocalized("Division (\(division.displayName))")
  }

  var divisionPlacementText: String {
    Self.placementText(medal.divisionPlacement)
  }

  var divisionTotalText: String? {
    Self.totalText(medal.divisionTotal, placement: medal.divisionPlacement)
  }

  var genderPlacementText: String {
    Self.placementText(medal.genderPlacement)
  }

  var genderTotalText: String? {
    Self.totalText(medal.genderTotal, placement: medal.genderPlacement)
  }

  /// What the user wrote about the day, or nothing when they wrote only whitespace.
  var noteText: String? {
    guard let note = medal.note?.trimmingCharacters(in: .whitespacesAndNewlines),
      !note.isEmpty
    else { return nil }

    return note
  }

  /// Whether the user kept anything of the day — photos, a note, or both.
  var hasDay: Bool {
    !medal.eventPhotos.isEmpty || noteText != nil
  }

  // MARK: - Functions
  /// A placement, or the unfilled marker when it was never recorded.
  private static func placementText(_ placement: Int?) -> String {
    guard let placement else { return unfilled }
    return "\(placement)"
  }

  /// The field a placement ran against, absent unless there is a placement to qualify.
  ///
  /// A total on its own would read as `— / 7373`, stating the size of a field the medal
  /// never records a position in.
  private static func totalText(_ total: Int?, placement: Int?) -> String? {
    guard let total, placement != nil else { return nil }
    return "/ \(total)"
  }

  /// Reloads the medal from Firestore and updates the local state, including the live
  /// record set so an edit elsewhere in the collection that demotes or promotes this
  /// medal is reflected on the "PR" tag without the user leaving the screen.
  ///
  /// The two fetches run concurrently through methods on `self` rather than `async let` on
  /// the repository directly: `self` is main-actor isolated and so can cross into a child
  /// task, where the injected `any MedalRepository` existential cannot.
  ///
  /// Whatever loads is applied, unless a newer reload's result already has been. A failed fetch
  /// throws `AppError.medalFetchFailed`, so the screen can say it is out of date rather than
  /// quietly keep showing the pre-edit medal; only the newest reload throws.
  func reloadMedal() async throws(AppError) {
    let load = reloads.begin()
    async let updatedMedal = fetchMedal()
    async let allMedals = fetchAllMedals()
    do {
      let updated = try await updatedMedal
      guard reloads.shouldApply(load) else { return }
      if let updated {
        medal = updated
      }
      let recordIDs = try await allMedals.personalRecordIDs
      guard reloads.shouldApply(load) else { return }
      personalRecordIDs = recordIDs
    } catch {
      guard reloads.isNewest(load) else { return }
      throw .medalFetchFailed(error.localizedDescription)
    }
  }

  /// Fetches this medal on its own, for the concurrent reload above.
  private func fetchMedal() async throws -> Medal? {
    try await repository.fetchMedal(id: medal.id, userId: medal.userID)
  }

  /// Turns the medal over to its other face, empty or not.
  func toggleFace() {
    faceInView = faceInView == .front ? .back : .front
  }

  /// How far the medal is turned, in degrees, with `face` in view: 0 for the front, 180 for the
  /// back. Animating between them gives each frame's angle, which `faceOpacity` reads.
  static func flipAngle(showing face: MedalFace) -> Double {
    face == .back ? 180 : 0
  }

  /// The medal's rotation with `face` in view: its flip angle while the medal `turns`, and none
  /// under Reduce Motion, where the faces crossfade in place.
  static func rotation(showing face: MedalFace, turns: Bool) -> Double {
    turns ? flipAngle(showing: face) : 0
  }

  /// How visible `face` is at `flipAngle`.
  ///
  /// While the medal `turns`, a face shows only while it faces the viewer, swapping at 90°
  /// where the medal is edge-on; a plain fade would show both faces across the whole turn.
  /// Under Reduce Motion the faces crossfade.
  static func faceOpacity(_ face: MedalFace, flipAngle: Double, turns: Bool) -> Double {
    let backProgress = flipAngle / 180
    if turns {
      let frontFacesViewer = flipAngle < 90
      return frontFacesViewer == (face == .front) ? 1 : 0
    }
    return face == .front ? 1 - backProgress : backProgress
  }

  /// The flip's motion: `motion.flip` while the medal `turns`, a fade under Reduce Motion.
  static func flipAnimation(turns: Bool) -> Animation {
    turns ? .Motion.flip : .Motion.flipReduced
  }

  /// Fetches the owner's whole collection, for the concurrent reload above.
  private func fetchAllMedals() async throws -> [Medal] {
    try await repository.fetchMedals(userId: medal.userID)
  }

  /// Deletes the medal from Firestore, then its front, back and event photos from Storage. The
  /// photos go only once the medal is gone, so a failed delete never leaves the medal pointing
  /// at deleted files; a photo that fails to delete is left behind rather than failing a
  /// delete that already happened. Offline, it throws `AppError.noInternetConnection` before
  /// deleting anything.
  func deleteMedal() async throws {
    guard await networkMonitor.isConnected() else { throw AppError.noInternetConnection }

    try await repository.deleteMedal(id: medal.id, userId: medal.userID)
    let owner = PhotoOwner.medal(userId: medal.userID, medalId: medal.id)
    for face in MedalFace.allCases {
      if let photoUrl = medal.photoUrls?[face] {
        try? await storageService.deletePhoto(url: photoUrl, ownedBy: owner)
      }
    }
    for eventPhoto in medal.eventPhotos {
      try? await storageService.deletePhoto(url: eventPhoto.imageUrl, ownedBy: owner)
    }
  }
}
