//
//  Color+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2026-03-04.
//

import SwiftUI

extension Color {

  // MARK: - Palette
  /// The design system's colour tokens, one per asset catalog entry.
  ///
  /// This is the only place an asset name is spelled. Everything below names a
  /// *role* and points here, so a pigment used by two components — gilt is both
  /// an earned record and a tier badge's outer ring — is written once.
  ///
  /// Only the roles below reference a pigment. A view or modifier that needs a colour
  /// no role names gets a new role rather than a pigment.
  struct Pigment {
    static let paper = Color("Paper")
    static let porcelain = Color("Porcelain")
    static let bone = Color("Bone")
    static let stone = Color("Stone")
    static let granite = Color("Granite")
    static let ash = Color("Ash")
    static let pewter = Color("Pewter")
    static let inkNavy = Color("InkNavy")
    static let obsidian = Color("Obsidian")
    static let slate = Color("Slate")
    static let mist = Color("Mist")
    static let taupe = Color("Taupe")
    static let gilt = Color("Gilt")
    static let bronze = Color("Bronze")
    static let champagne = Color("Champagne")
    static let laurel = Color("Laurel")
    static let cinnabar = Color("Cinnabar")
  }

  // MARK: - Roles
  struct Background {
    static let primary = Pigment.paper
  }

  struct Surface {
    static let primary = Pigment.porcelain
    static let secondary = Pigment.bone
    static let tertiary = Pigment.granite
    static let quaternary = Pigment.stone
  }

  struct Border {
    static let primary = Pigment.ash
    static let placeholder = Pigment.pewter
  }

  struct Text {
    static let primary = Pigment.inkNavy
    static let secondary = Pigment.slate
    static let tertiary = Pigment.mist
    static let placeholder = Pigment.taupe
    /// Text on an `Accent` fill.
    static let inverse = Pigment.paper
  }

  /// Every control's fill, border and tint. Gold never takes this job.
  struct Accent {
    static let primary = Pigment.inkNavy
  }

  /// Something the user earned — a medal's ring, a tier mark. Never tappable, and never
  /// a value: a finish time is text, not an award.
  struct Record {
    static let earned = Pigment.gilt
    /// The PR badge fill. Fixed in both appearances.
    static let personalBest = Pigment.champagne
    /// Text on `personalBest`. Fixed too, so it never inverts out from under its fill.
    static let onPersonalBest = Pigment.obsidian
  }

  /// The double-ring seal, earned and locked. Locked keeps the same silhouette in
  /// neutral greys — no gold until it is earned.
  struct TierBadge {
    static let earnedOuter = Pigment.gilt
    static let earnedInner = Pigment.bronze
    static let earnedNumeral = Pigment.gilt
    static let lockedOuter = Pigment.pewter
    static let lockedInner = Pigment.ash
    static let lockedIcon = Pigment.mist
  }

  struct Status {
    static let success = Pigment.laurel
    static let error = Pigment.cinnabar
  }
}
