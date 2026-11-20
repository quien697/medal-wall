//
//  PhotoChecks.swift
//  MedalWall
//
//  Created by Quien on 2026-11-20.
//

/// Counts a form's photo size checks still in progress, so Save waits until they end and a photo
/// is never left out of a save.
struct PhotoChecks {
  private var inProgress = 0

  /// Whether any photo is still being checked.
  var isChecking: Bool { inProgress > 0 }

  /// Records that a check started (`true`) or ended (`false`). An end with no check in progress
  /// is ignored, so the count never goes below zero.
  mutating func changed(isChecking: Bool) {
    inProgress = max(0, inProgress + (isChecking ? 1 : -1))
  }
}
