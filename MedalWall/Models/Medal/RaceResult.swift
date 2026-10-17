//
//  RaceResult.swift
//  MedalWall
//
//  Created by Quien on 2026-10-17.
//

import Foundation

/// What a medal's race produced. For a distance race that is a finish time, stored in seconds.
struct RaceResult: Codable, Hashable {
  var value: Double
  var unit: ResultUnit

  /// A finish time of `seconds`.
  static func seconds(_ seconds: TimeInterval) -> RaceResult {
    RaceResult(value: seconds, unit: .seconds)
  }
}

/// The unit a `RaceResult` is stored in.
enum ResultUnit: String, Codable {
  case seconds
}
