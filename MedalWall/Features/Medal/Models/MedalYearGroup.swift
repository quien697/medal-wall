//
//  MedalYearGroup.swift
//  MedalWall
//
//  Created by Quien on 2026-09-07.
//

import Foundation

/// One year's worth of medals, as the medal list presents them.
///
/// The year is the identity: a collection yields at most one group per year, so `ForEach`
/// keeps a stable row across a reload without reaching for the medals inside.
nonisolated struct MedalYearGroup: Identifiable {
  var id: Int { year }
  let year: Int
  let medals: [Medal]
}
