//
//  PlaceholderImage.swift
//  MedalWall
//
//  Created by Quien on 2026-08-28.
//

import SwiftUI

/// Stands in for an image that is missing, one glyph per asset.
///
/// This is content that happens to have no photo, so it carries a solid edge —
/// the dashed edge belongs to `EmptyPhotoSlot`, the only placeholder that is tappable.
struct PlaceholderImage: View {
  private let imageType: ImageType

  init(as imageType: ImageType) {
    self.imageType = imageType
  }

  var body: some View {
    Image(systemName: imageType.placeholderSymbol)
      .resizable()
      .scaledToFit()
      .frame(width: imageType.size.width * 0.33)
      .foregroundStyle(Color.Text.secondary)
      .frame(width: imageType.size.width, height: imageType.size.height)
      .background(Color.Surface.tertiary)
      .clipShape(imageType.shape)
      .overlay(
        imageType.shape
          .stroke(Color.Pigment.pewter, lineWidth: 1.5)
      )
  }
}

#Preview {
  VStack(spacing: 20) {
    HStack(spacing: 20) {
      PlaceholderImage(as: .avatar)

      PlaceholderImage(as: .raceHero)
    }  // HStack

    PlaceholderImage(as: .medal)

    HStack(spacing: 20) {
      PlaceholderImage(as: .event)

      PlaceholderImage(as: .eventThumbnail)
    }  // HStack
  }  // VStack
  .padding(40)
  .background(Color.Background.primary)
}
