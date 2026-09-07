//
//  Medal+Stats.swift
//  MedalWall
//
//  Created by Quien on 2026-05-28.
//

import Foundation

extension Array where Element == Medal {
  var fullCount: Int { filter { $0.distance.category == .full }.count }
  var halfCount: Int { filter { $0.distance.category == .half }.count }

  var bestFullTime: TimeInterval? {
    filter { $0.distance.category == .full }
      .compactMap { $0.finishTime }
      .filter { $0 > 0 }
      .min()
  }

  var bestHalfTime: TimeInterval? {
    filter { $0.distance.category == .half }
      .compactMap { $0.finishTime }
      .filter { $0 > 0 }
      .min()
  }
}

// MARK: - Ordering & Grouping
extension Array where Element == Medal {
  /// The collection in presentation order: most recent first, ties broken by `id`.
  ///
  /// Firestore returns documents unordered, so the tiebreak is what keeps a year's rows
  /// from shuffling between launches when two races share a date.
  var sortedForDisplay: [Medal] {
    sorted { lhs, rhs in
      lhs.date == rhs.date ? lhs.id < rhs.id : lhs.date > rhs.date
    }
  }

  /// The collection split into one group per calendar year, most recent year first.
  ///
  /// A year with no medals yields no group, so the list never renders an empty year.
  var groupedByYear: [MedalYearGroup] {
    let calendar = Calendar.current
    let grouped = Dictionary(grouping: sortedForDisplay) {
      calendar.component(.year, from: $0.date)
    }
    return grouped.keys.sorted(by: >).map { year in
      MedalYearGroup(year: year, medals: grouped[year] ?? [])
    }
  }
}

// MARK: - Distance Filtering
extension Array where Element == Medal {
  /// The distance categories present in the collection, longest first.
  ///
  /// Categories are compared by measured distance, so a custom 42.195 collapses onto
  /// `.full` rather than offering the same distance as a second option. Non-finite
  /// values (`NaN`, `±Inf`) are dropped before the sort — sorting a `Set<Double>` that
  /// contains them violates strict weak ordering and traps.
  var distanceCategoriesOwned: [RaceDistanceCategory] {
    let finiteValues = map { $0.distance.category.value }.filter(\.isFinite)
    let distances = Set(finiteValues)
    return distances.sorted(by: >).map { RaceDistanceCategory(value: $0) }
  }

  /// The medals `distanceFilter` selects, across every race type at that distance.
  func filtered(by distanceFilter: MedalDistanceFilter) -> [Medal] {
    switch distanceFilter {
    case .all:
      return self
    case .category(let category):
      return filter { $0.distance.category.value == category.value }
    }
  }

  /// How many medals `distanceFilter` selects.
  func count(for distanceFilter: MedalDistanceFilter) -> Int {
    filtered(by: distanceFilter).count
  }
}

// MARK: - Personal Records
extension Array where Element == Medal {
  /// The fastest medal at each distance, keyed by its measured category.
  ///
  /// A record belongs to the collection rather than to a medal, so it is derived here and
  /// never persisted — adding, editing, or deleting a medal moves it with no stored value
  /// left to go stale.
  ///
  /// Only a finish time greater than zero is eligible. A stored zero or negative would
  /// otherwise be the minimum of its category and claim a record it never earned.
  ///
  /// Iteration follows `sortedForDisplay` so the outcome cannot depend on the order
  /// Firestore returned: within a tied time the earlier date wins, and medals tied on both
  /// time and date resolve by the same `id` ordering every run.
  var personalRecords: [RaceDistanceCategory: Medal] {
    var records: [RaceDistanceCategory: Medal] = [:]

    for medal in sortedForDisplay {
      guard let finishTime = medal.finishTime, finishTime > 0 else { continue }
      let category = RaceDistanceCategory(value: medal.distance.category.value)

      guard let leader = records[category] else {
        records[category] = medal
        continue
      }

      let leaderTime = leader.finishTime ?? .greatestFiniteMagnitude
      if finishTime < leaderTime || (finishTime == leaderTime && medal.date < leader.date) {
        records[category] = medal
      }
    }

    return records
  }

  /// The ids of the medals holding a record, so a row can ask in constant time.
  ///
  /// Derived from `personalRecords` rather than computed separately, so the rule for what
  /// counts as a record is stated once.
  var personalRecordIDs: Set<String> {
    Set(personalRecords.values.map(\.id))
  }
}
