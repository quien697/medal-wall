//
//  DeletePrompt.swift
//  MedalWall
//
//  Created by Quien on 2026-09-17.
//

import Foundation

/// What a delete confirmation says, so the wording lives in one testable place rather
/// than at each call site.
///
/// A case carries the subject it names — user data such as a race or medal name, which is
/// interpolated and never translated, or a year the alert formats itself. Nothing else is
/// passed in: the copy belongs to the case, not to the screen raising it.
nonisolated enum DeletePrompt: Equatable {
  case medal(name: String)
  case race(name: String)
  case edition(year: Int)

  /// Names what is about to be deleted.
  var title: String {
    switch self {
    case .medal(let name), .race(let name):
      .appLocalized("Delete \(name)?")
    case .edition(let year):
      .appLocalized("Delete \(String(year)) edition?")
    }
  }

  /// What the delete takes with it.
  ///
  /// Only a race says more than that it cannot be undone, because only a race deletion
  /// reaches further than itself: `deleteRace` removes every edition first, while medals
  /// survive on purpose — they hold no reference back to the race.
  var message: String {
    switch self {
    case .race:
      .appLocalized("Deleting it also deletes all editions. Medals you've added are kept.")
    case .medal, .edition:
      .appLocalized("This can't be undone.")
    }
  }
}
