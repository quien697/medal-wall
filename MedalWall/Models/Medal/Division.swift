//
//  Division.swift
//  MedalWall
//
//  Created by Quien on 2026-04-01.
//

/// A race division combining gender and age group bracket.
/// Displayed as e.g. "Male 30-34", "Female Under 20".
/// Stored as a pipe-separated raw string: "male|30-34".
struct Division: Hashable, Sendable {
  var gender: Gender
  var ageGroup: AgeGroup

  nonisolated var rawValue: String {
    "\(gender.rawValue) \(ageGroup.rawValue)"
  }

  var displayName: String {
    "\(gender.shortName) \(ageGroup.displayName)"
  }

  init(gender: Gender, ageGroup: AgeGroup) {
    self.gender = gender
    self.ageGroup = ageGroup
  }

  /// Reconstructs a `Division` from its persisted raw value.
  /// Splits on the last space, e.g. `"male from30to34"` → `.male` + `.from30to34`.
  nonisolated init?(rawValue: String) {
    guard let separatorIndex = rawValue.lastIndex(of: " ") else { return nil }

    let genderRaw = String(rawValue[rawValue.startIndex..<separatorIndex])
    let ageGroupRaw = String(rawValue[rawValue.index(after: separatorIndex)...])
    guard let gender = Gender(rawValue: genderRaw),
      let ageGroup = AgeGroup(rawValue: ageGroupRaw)
    else { return nil }

    self.gender = gender
    self.ageGroup = ageGroup
  }
}
