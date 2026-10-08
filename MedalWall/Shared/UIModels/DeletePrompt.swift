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

  /// What the delete takes with it, or when it happens.
  ///
  /// A race says more than that it cannot be undone, because a race deletion reaches further
  /// than itself: `deleteRace` removes every edition first, while medals survive on purpose —
  /// they hold no reference back to the race. An edition is only staged for deletion in the
  /// race editor, so it says the delete waits for the race save, which Cancel still undoes.
  var message: String {
    switch self {
    case .race:
      .appLocalized("Deleting it also deletes all editions. Medals you've added are kept.")
    case .medal:
      .appLocalized("This can't be undone.")
    case .edition:
      .appLocalized("It's deleted when you save the race.")
    }
  }
}
