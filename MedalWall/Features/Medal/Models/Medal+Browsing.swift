//
//  Medal+Browsing.swift
//  MedalWall
//
//  Created by Quien on 2026-09-28.
//

import Foundation

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
    let grouped = Dictionary(grouping: sortedForDisplay) { $0.date.year }
    return grouped.keys.sorted(by: >).map { year in
      MedalYearGroup(year: year, medals: grouped[year] ?? [])
    }
  }
}

// MARK: - Distance Filtering
extension Array where Element == Medal {
  /// The distance categories present in the collection, longest real length first.
  ///
  /// A category is its exact value and unit, so `10K` and `10 mi` are two options and a
  /// `42.2 km` medal does not join `Full`. Where two categories are the same real length,
  /// kilometres come first, as in `RaceEvent`'s ordering. Non-finite values (`NaN`,
  /// `±Inf`) are dropped after the Set — sorting one violates strict weak ordering and
  /// traps.
  var distanceCategoriesOwned: [RaceDistanceCategory] {
    Set(map(\.raceEvent.category))
      .filter { $0.value.isFinite }
      .sorted { lhs, rhs in
        lhs.kilometers != rhs.kilometers
          ? lhs.kilometers > rhs.kilometers
          : lhs.unit == .kilometers && rhs.unit == .miles
      }
  }

  /// The medals `distanceFilter` selects, across every race type at that distance.
  func filtered(by distanceFilter: MedalDistanceFilter) -> [Medal] {
    switch distanceFilter {
    case .all:
      return self
    case .category(let category):
      return filter { $0.raceEvent.category == category }
    }
  }

  /// How many medals `distanceFilter` selects.
  func count(for distanceFilter: MedalDistanceFilter) -> Int {
    filtered(by: distanceFilter).count
  }
}

// MARK: - Personal Records
extension Array where Element == Medal {
  /// The fastest medal at each distance, keyed by its category.
  ///
  /// A record belongs to the collection rather than to a medal, so it is derived here and
  /// never persisted — adding, editing, or deleting a medal moves it with no stored value
  /// left to go stale.
  ///
  /// Only a finish time greater than zero is eligible. A stored zero or negative would
  /// otherwise be the minimum of its category and claim a record it never earned. Nor is a
  /// distance of zero or less, or one that is not a finite number: NaN never equals itself,
  /// so each such medal would key a record of its own.
  ///
  /// Iteration follows `sortedForDisplay` so the outcome cannot depend on the order
  /// Firestore returned: within a tied time the earlier date wins, and medals tied on both
  /// time and date resolve by the same `id` ordering every run.
  var personalRecords: [RaceDistanceCategory: Medal] {
    var records: [RaceDistanceCategory: Medal] = [:]

    for medal in sortedForDisplay {
      let category = medal.raceEvent.category
      guard let finishTime = medal.recordedFinishTime, category.value > 0, category.value.isFinite
      else { continue }

      guard let leader = records[category] else {
        records[category] = medal
        continue
      }

      let leaderTime = leader.recordedFinishTime ?? .greatestFiniteMagnitude
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

  /// The record at each distance that has one, longest distance first.
  ///
  /// Walks `distanceCategoriesOwned` rather than sorting `personalRecords` by key, so the
  /// carousel and the filter chips share one ordering rule instead of keeping two in
  /// agreement by hand. Both sides key on the medal's own category, so each record finds
  /// its chip.
  ///
  /// A distance whose medals are all untimed holds no record and drops out here, which is
  /// what leaves it out of the carousel while the filter still offers it.
  var personalBests: [MedalPersonalBest] {
    let records = personalRecords

    return distanceCategoriesOwned.compactMap { category in
      records[category].map { MedalPersonalBest(category: category, medal: $0) }
    }
  }
}
