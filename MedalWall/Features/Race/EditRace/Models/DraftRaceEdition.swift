//
//  DraftRaceEdition.swift
//  MedalWall
//
//  Created by Quien on 2026-03-28.
//

import Foundation
import UIKit

/// A temporary, unmanaged copy of edition data for editing
/// This struct is NOT tracked by SwiftData and can be freely edited
struct DraftRaceEdition: Identifiable {
  let id: UUID
  let sourceEditionId: UUID?
  var year: Int
  var isOneDay: Bool
  var startDate: Date
  var endDate: Date
  var photoData: Data? = nil
  var distances: [RaceDistance] = []
  
  var photo: UIImage? {
    if let photoData {
      return UIImage(data: photoData)
    }
    return nil
  }
  
  var dateDisplayLabel: String {
    let start = startDate.formatted(.dateTime.month().day())
    let end = ", \(endDate.formatted(.dateTime.month().day()))"
    return "\(start)\(isOneDay ? "" : end)"
  }
  
  init(from edition: RaceEdition) {
    self.id = UUID()
    self.sourceEditionId = UUID()
    self.year = edition.year
    self.isOneDay = edition.isOneDay
    self.startDate = edition.startDate
    self.endDate = edition.endDate
    self.photoData = nil
    self.distances = edition.distances
  }
  
  init() {
    self.id = UUID()
    self.sourceEditionId = nil
    self.year = Calendar.current.component(.year, from: Date())
    self.isOneDay = true
    self.startDate = Date()
    self.endDate = Date()
    self.photoData = nil
    self.distances = []
  }
}
