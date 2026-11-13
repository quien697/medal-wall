//
//  PlaceholderImage.swift
//  MedalWall
//
//  Created by Quien on 2026-08-28.
//

import SwiftUI

/// Stands in for an image that is missing, one glyph per asset, with an optional label beneath
/// it.
///
/// This is content that happens to have no photo, so it carries a solid edge —
/// the dashed edge belongs to `EmptyPhotoSlot`, the only placeholder that is tappable.
struct PlaceholderImage: View {
  private let imageType: ImageType
  private let text: LocalizedStringKey?

  /// Creates the placeholder for `imageType`, with `text` beneath the glyph when given.
  init(as imageType: ImageType, text: LocalizedStringKey? = nil) {
    self.imageType = imageType
    self.text = text
  }

  var body: some View {
    VStack(spacing: .Space.inline) {
      Image(systemName: imageType.placeholderSymbol)
        .resizable()
        .scaledToFit()
        .frame(width: imageType.size.width * 0.33)

      if let text {
        Text(text)
          .font(.TypeScale.overline)
          .tracking(.Tracking.label)
          .textCase(.uppercase)
      }
    }  // VStack
    .foregroundStyle(Color.Text.secondary)
    .frame(width: imageType.size.width, height: imageType.size.height)
    .background(Color.Surface.tertiary)
    .clipShape(imageType.shape)
    .overlay(
      imageType.shape
        .stroke(Color.Border.placeholder, lineWidth: 1.5)
    )
  }
}

#Preview {
  VStack(spacing: 20) {
    HStack(spacing: 20) {
      PlaceholderImage(as: .avatar)

      PlaceholderImage(as: .raceHero)
    }  // HStack

    PlaceholderImage(as: .medal, text: "Front")

    HStack(spacing: 20) {
      PlaceholderImage(as: .event)

      PlaceholderImage(as: .eventThumbnail)
    }  // HStack
  }  // VStack
  .padding(40)
  .background(Color.Background.primary)
}
