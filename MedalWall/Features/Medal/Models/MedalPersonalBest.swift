//
//  MedalPersonalBest.swift
//  MedalWall
//
//  Created by Quien on 2026-09-08.
//

import Foundation

/// The record at one distance: the medal holding it, and the distance it was set at.
///
/// The distance is the identity, not the medal. A faster medal taking the record over must
/// update the card in place rather than replace it — identifying by `medal.id` would tear
/// the card down and re-insert it, which the carousel would show as a jump to another page
/// while the user is reading it.
nonisolated struct MedalPersonalBest: Identifiable {
  var id: Double { category.value }
  let category: RaceDistanceCategory
  let medal: Medal
}
