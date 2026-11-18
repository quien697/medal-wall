//
//  MedalPhotoUrls.swift
//  MedalWall
//
//  Created by Quien on 2026-11-13.
//

import Foundation

/// A medal's photo URLs, stored as its `photoUrls` map with a key only for a face that has a
/// photo, named as the face's Storage folder is.
///
/// A medal without photos stores no map: its `photoUrls` is `nil` rather than empty. An empty
/// map another client stored still decodes, as no photos.
struct MedalPhotoUrls: Codable, Hashable {
  var front: String?
  var back: String?

  /// Whether neither face has a photo.
  var isEmpty: Bool {
    front == nil && back == nil
  }

  /// The URL of `face`'s photo, if it has one.
  subscript(face: MedalFace) -> String? {
    switch face {
    case .front: front
    case .back: back
    }
  }
}
