//
//  MedalFace.swift
//  MedalWall
//
//  Created by Quien on 2026-11-03.
//

import SwiftUI

/// One side of a medal, each with its own optional photo. `allCases` runs front first, the
/// order the form and the details show the faces in.
enum MedalFace: CaseIterable {
  case front
  case back

  // Each wording is its own catalog key rather than built from `title`, so a translation can
  // word each phrase its own way.

  /// The face's name, as a catalog key for `Text`, so it resolves in the view's locale.
  var title: LocalizedStringKey {
    switch self {
    case .front: "Front"
    case .back: "Back"
    }
  }

  /// What an empty slot for this face reads.
  var addTitle: LocalizedStringKey {
    switch self {
    case .front: "Add front"
    case .back: "Add back"
    }
  }

  /// The title of the photo options a slot for this face offers.
  var photoTitle: LocalizedStringKey {
    switch self {
    case .front: "Front photo"
    case .back: "Back photo"
    }
  }
}
