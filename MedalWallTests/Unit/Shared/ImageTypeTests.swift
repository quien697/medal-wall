//
//  ImageTypeTests.swift
//  MedalWall
//
//  Created by Quien on 2026-08-28.
//

import Testing

@testable import MedalWall

@MainActor
struct ImageTypeTests {

  @Test("Each asset carries its own placeholder glyph")
  func testPlaceholderSymbolPerAsset() {
    #expect(ImageType.avatar.placeholderSymbol == "person.fill")
    #expect(ImageType.avatarThumbnail.placeholderSymbol == "person.fill")
    #expect(ImageType.raceHero.placeholderSymbol == "figure.run")
    #expect(ImageType.raceThumbnail.placeholderSymbol == "figure.run")
    #expect(ImageType.medal.placeholderSymbol == "medal.fill")
    #expect(ImageType.event.placeholderSymbol == "photo")
    #expect(ImageType.eventThumbnail.placeholderSymbol == "photo")
  }
}
