//
//  RaceEdition+Computed.swift
//  MedalWall
//
//  Created by Quien on 2026-09-28.
//

import Foundation

extension RaceEdition {
  var isOneDay: Bool {
    Calendar.current.isDate(startDate, inSameDayAs: endDate)
  }

  var dateDisplayLabel: String {
    Self.dateDisplayLabel(startDate: startDate, endDate: endDate, isOneDay: isOneDay)
  }

  /// The start date alone for a one-day event, otherwise the start and end dates.
  ///
  /// Shared with `DraftRaceEdition`, whose `isOneDay` is the user's choice rather than
  /// derived from its dates, so an edition reads the same while it is being edited.
  static func dateDisplayLabel(startDate: Date, endDate: Date, isOneDay: Bool) -> String {
    let start = startDate.formattedMonthDay()
    let end = ", \(endDate.formattedMonthDay())"
    return "\(start)\(isOneDay ? "" : end)"
  }
}
