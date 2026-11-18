//
//  MedalPhotoUrlsTests.swift
//  MedalWall
//
//  Created by Quien on 2026-11-13.
//

import Foundation
import Testing

@testable import MedalWall

/// Covers a medal's photo URLs, stored as one `photoUrls` map keyed by face.
struct MedalPhotoUrlsTests {

  @Test("each face reads its own URL")
  func testEachFaceReadsItsURL() {
    let photoUrls = MedalPhotoUrls(front: "front.jpg", back: "back.jpg")

    #expect(photoUrls[.front] == "front.jpg")
    #expect(photoUrls[.back] == "back.jpg")
  }

  @Test("photo URLs are empty only when neither face has one")
  func testIsEmpty() {
    #expect(MedalPhotoUrls().isEmpty)
    #expect(!MedalPhotoUrls(front: "front.jpg").isEmpty)
    #expect(!MedalPhotoUrls(back: "back.jpg").isEmpty)
  }

  /// Another client may store `photoUrls: {}`; a medal must still load.
  @Test("an empty stored map decodes as no photos")
  func testEmptyMapDecodes() throws {
    let photoUrls = try JSONDecoder().decode(MedalPhotoUrls.self, from: Data("{}".utf8))

    #expect(photoUrls.isEmpty)
  }
}
