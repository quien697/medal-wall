//
//  ImageTypeTests.swift
//  MedalWall
//
//  Created by Quien on 2026-08-28.
//

import SwiftUI
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

  // MARK: - Search rows
  /// `.medalRing()` pads the photo by 3 pt on every side, so the ringed medal takes the race
  /// image's footprint and the two sections' text columns line up.
  @Test("A ringed search medal takes the same footprint as a search race image")
  func testSearchRowImagesShareAFootprint() {
    let ringedMedal = ImageType.medalSearchThumbnail.size.width + 2 * 3

    #expect(ringedMedal == ImageType.raceSearchThumbnail.size.width)
    #expect(ImageType.medalSearchThumbnail.size.width == ImageType.medalSearchThumbnail.size.height)
    #expect(ImageType.raceSearchThumbnail.size.width == ImageType.raceSearchThumbnail.size.height)
  }

  @Test("A search row draws a medal as a circle and a race as a rounded rectangle")
  func testSearchRowImageShapes() {
    let rect = CGRect(x: 0, y: 0, width: 52, height: 52)

    #expect(
      ImageType.medalSearchThumbnail.shape.path(in: rect)
        == ImageType.medalThumbnail.shape.path(in: rect))
    #expect(
      ImageType.raceSearchThumbnail.shape.path(in: rect)
        == ImageType.raceThumbnail.shape.path(in: rect))
  }

  @Test("A search row's missing image shows its asset's glyph")
  func testSearchRowPlaceholderSymbols() {
    #expect(ImageType.medalSearchThumbnail.placeholderSymbol == "medal.fill")
    #expect(ImageType.raceSearchThumbnail.placeholderSymbol == "figure.run")
  }
}
