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
  /// Reach for a role first. Use a pigment directly only where no role fits.
  struct Pigment {
    static let paper = Color("Paper")
    static let porcelain = Color("Porcelain")
    static let bone = Color("Bone")
    static let stone = Color("Stone")
    static let ash = Color("Ash")
    static let pewter = Color("Pewter")
    static let inkNavy = Color("InkNavy")
    static let navy900 = Color("Navy900")
    static let navy950 = Color("Navy950")
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
    static let tertiary = Pigment.stone
  }

  struct Border {
    static let primary = Pigment.ash
    static let gray = Pigment.ash  // delete later
  }

  struct Text {
    static let primary = Pigment.inkNavy
    static let secondary = Pigment.slate
    static let tertiary = Pigment.mist
    static let placeholder = Pigment.taupe
  }

  /// Something the user earned — a finish time, a PR, a medal's ring.
  struct Record {
    static let primary = Pigment.gilt
    static let champagne = Pigment.champagne
    static let ink = Pigment.navy950
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

  // MARK: - Pending removal
  struct Card {  // delete later
    struct Background {
      static let primary = Pigment.porcelain
      static let secondary = Pigment.bone
      static let tertiary = Pigment.stone
    }
  }

  struct Gold {  // delete later
    static let primary = Pigment.gilt
    static let secondary = Pigment.champagne
  }
}
