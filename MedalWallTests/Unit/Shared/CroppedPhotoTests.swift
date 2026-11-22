//
//  CroppedPhotoTests.swift
//  MedalWall
//
//  Created by Quien on 2026-11-22.
//

import Testing
import UIKit

@testable import MedalWall

/// Covers a cropped photo's size check, which names the crop in its error.
struct CroppedPhotoTests {
  @Test("a crop whose JPEG is over the upload limit is refused as a crop too large")
  func testCropOverLimitIsRefused() throws {
    let noise = try #require(TestPhotos.noise())

    #expect(throws: AppError.croppedPhotoTooLarge) {
      try CroppedPhoto(checking: noise)
    }
  }
}
