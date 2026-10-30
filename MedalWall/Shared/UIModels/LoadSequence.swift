//
//  LoadSequence.swift
//  MedalWall
//
//  Created by Quien on 2026-10-30.
//

/// Orders one kind of load on a screen. Loads are never cancelled, so they can overlap: a load's
/// result applies unless a newer load's result already has, and only the newest started load
/// presents an error or ends the loading state.
struct LoadSequence {
  private var started = 0
  private var applied = 0

  /// Numbers a new load.
  mutating func begin() -> Int {
    started += 1
    return started
  }

  /// Whether `load`'s result may apply, because no newer load's result has. Records `load` as
  /// applied, so a load that applies in steps stays applicable.
  mutating func shouldApply(_ load: Int) -> Bool {
    guard load >= applied else { return false }
    applied = load
    return true
  }

  /// Whether `load` is the newest one started.
  func isNewest(_ load: Int) -> Bool {
    load == started
  }
}
