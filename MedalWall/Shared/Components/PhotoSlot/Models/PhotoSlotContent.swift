//
//  PhotoSlotContent.swift
//  MedalWall
//
//  Created by Quien on 2026-11-14.
//

import UIKit

/// What a photo slot shows.
enum PhotoSlotContent: Equatable {
  /// The photo the form holds.
  case photo(UIImage)
  /// A stored photo that is still downloading.
  case loading
  /// A stored photo that could not be downloaded.
  case failed
  /// No photo: the slot invites one.
  case empty

  /// Whether the slot holds a photo, shown or not, that Remove Photo can remove.
  var holdsPhoto: Bool {
    self != .empty
  }
}
