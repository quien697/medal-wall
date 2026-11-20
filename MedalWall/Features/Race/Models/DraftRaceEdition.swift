//
//  DraftRaceEdition.swift
//  MedalWall
//
//  Created by Quien on 2026-03-28.
//

import Foundation
import UIKit

/// A local, unmanaged copy of edition data staged for editing.
/// Writes only reach Firestore when the parent race save is confirmed.
struct DraftRaceEdition: Identifiable {
  // MARK: - Identity
  let id: String
  /// `nil` for a new edition not yet in Firestore; equals `id` for an existing one.
  let sourceEditionId: String?

  // MARK: - Data
  var year: Int
  var isOneDay: Bool
  var startDate: Date
  var endDate: Date
  var distances: [RaceEvent]
  let createdBy: String

  // MARK: - Photo
  /// The current Firestore URL, carried forward until save resolves a new one.
  var storedPhotoUrl: String?
  /// A new photo cropped this session, which save uploads as it is; `nil` if unchanged.
  var newPhoto: CroppedPhoto?
  /// `true` when the user explicitly removed the photo this session.
  var isPhotoRemoved: Bool

  // MARK: - Tracking
  /// `true` when any field was changed this session. Only checked for existing editions.
  var isModified: Bool

  // MARK: - Init
  /// Creates a draft backed by an existing Firestore edition.
  init(from edition: RaceEdition) {
    self.id = edition.id
    self.sourceEditionId = edition.id
    self.year = edition.year
    self.isOneDay = edition.isOneDay
    self.startDate = edition.startDate
    self.endDate = edition.endDate
    self.distances = edition.raceEvents
    self.createdBy = edition.createdBy
    self.storedPhotoUrl = edition.photoUrl
    self.newPhoto = nil
    self.isPhotoRemoved = false
    self.isModified = false
  }

  /// Creates a new draft with no Firestore backing.
  init(
    year: Int,
    isOneDay: Bool,
    startDate: Date,
    endDate: Date,
    distances: [RaceEvent],
    createdBy: String
  ) {
    self.id = UUID().uuidString
    self.sourceEditionId = nil
    self.year = year
    self.isOneDay = isOneDay
    self.startDate = startDate
    self.endDate = endDate
    self.distances = distances
    self.createdBy = createdBy
    self.storedPhotoUrl = nil
    self.newPhoto = nil
    self.isPhotoRemoved = false
    self.isModified = false
  }

  // MARK: - Computed
  var displayPhotoUrl: String? {
    guard newPhoto == nil, !isPhotoRemoved else { return nil }
    return storedPhotoUrl
  }

  var dateDisplayLabel: String {
    RaceEdition.dateDisplayLabel(startDate: startDate, endDate: endDate, isOneDay: isOneDay)
  }
}
