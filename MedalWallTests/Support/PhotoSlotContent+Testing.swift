//
//  PhotoSlotContent+Testing.swift
//  MedalWall
//
//  Created by Quien on 2026-11-20.
//

import UIKit

extension PhotoSlotContent {
  /// The photo the slot shows, if any, so a test can check it is the same object: `==` on
  /// `UIImage` compares image data, and the test photos share theirs.
  var shownPhoto: UIImage? {
    guard case .photo(let photo) = self else { return nil }
    return photo
  }
}
