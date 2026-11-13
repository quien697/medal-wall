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

  // MARK: - Medal images
  @Test("Medal images are squares with image corners, not circles")
  func testMedalImagesAreRoundedSquares() {
    let rect = CGRect(x: 0, y: 0, width: 96, height: 96)
    let roundedSquare = RoundedRectangle(cornerRadius: .Radius.image).path(in: rect)

    #expect(ImageType.medal.shape.path(in: rect) == roundedSquare)
    #expect(ImageType.medalThumbnail.shape.path(in: rect) == roundedSquare)
    #expect(ImageType.medalSearchThumbnail.shape.path(in: rect) == roundedSquare)
  }

  @Test("Medal images are 280 pt in the details, 96 pt in the list and 46 pt in search")
  func testMedalImageSizes() {
    #expect(ImageType.medal.size == CGSize(width: 280, height: 280))
    #expect(ImageType.medalThumbnail.size == CGSize(width: 96, height: 96))
    #expect(ImageType.medalSearchThumbnail.size == CGSize(width: 46, height: 46))
  }

  @Test("Avatars stay circles")
  func testAvatarsStayCircles() {
    let rect = CGRect(x: 0, y: 0, width: 100, height: 100)

    #expect(ImageType.avatar.shape.path(in: rect) == Circle().path(in: rect))
    #expect(ImageType.avatarThumbnail.shape.path(in: rect) == Circle().path(in: rect))
  }

  @Test("A search row's missing image shows its asset's glyph")
  func testSearchRowPlaceholderSymbols() {
    #expect(ImageType.medalSearchThumbnail.placeholderSymbol == "medal.fill")
    #expect(ImageType.raceSearchThumbnail.placeholderSymbol == "figure.run")
  }
}
