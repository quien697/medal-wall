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
  var distances: [RaceDistance]
  let createdBy: String
  
  // MARK: - Photo
  /// The current Firestore URL, carried forward until save resolves a new one.
  var existingPhotoUrl: String?
  /// Raw data for a new photo chosen this session; `nil` if unchanged.
  var newPhotoData: Data?
  /// `true` when the user explicitly removed the photo this session.
  var isPhotoCleared: Bool
  
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
    self.distances = edition.distances
    self.createdBy = edition.createdBy
    self.existingPhotoUrl = edition.photoUrl
    self.newPhotoData = nil
    self.isPhotoCleared = false
    self.isModified = false
  }
  
  /// Creates a new draft with no Firestore backing.
  init(year: Int, isOneDay: Bool, startDate: Date, endDate: Date, distances: [RaceDistance], createdBy: String) {
    self.id = UUID().uuidString
    self.sourceEditionId = nil
    self.year = year
    self.isOneDay = isOneDay
    self.startDate = startDate
    self.endDate = endDate
    self.distances = distances
    self.createdBy = createdBy
    self.existingPhotoUrl = nil
    self.newPhotoData = nil
    self.isPhotoCleared = false
    self.isModified = false
  }
  
  // MARK: - Computed
  
  var displayPhoto: UIImage? {
    newPhotoData.flatMap { UIImage(data: $0) }
  }
  
  var displayPhotoUrl: String? {
    guard newPhotoData == nil, !isPhotoCleared else { return nil }
    return existingPhotoUrl
  }
  
  var dateDisplayLabel: String {
    let start = startDate.formatted(.dateTime.month().day())
    let end = ", \(endDate.formatted(.dateTime.month().day()))"
    return "\(start)\(isOneDay ? "" : end)"
  }
}
