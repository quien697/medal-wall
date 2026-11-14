//
//  EmptyPhotoSlot.swift
//  MedalWall
//
//  Created by Quien on 2026-08-28.
//

import SwiftUI

/// An empty slot inviting a photo: a plus, with an optional label beneath it.
///
/// The dashed edge on a clear ground is reserved for this one placeholder, because it
/// is the only one that is an affordance — everything else missing uses
/// `PlaceholderImage`. It is drawn at its `imageType`'s size, shrinking to the space it is
/// given.
struct EmptyPhotoSlot: View {
  private let imageType: ImageType
  private let text: LocalizedStringKey?

  /// Creates the empty slot for `imageType`, with `text` beneath the plus when given.
  init(as imageType: ImageType, text: LocalizedStringKey? = nil) {
    self.imageType = imageType
    self.text = text
  }

  var body: some View {
    VStack(spacing: .Space.inline) {
      Image(systemName: "plus")
        .font(.TypeScale.title1)
        .foregroundStyle(Color.Text.secondary)

      if let text {
        Text(text)
          .font(.TypeScale.headline)
          .foregroundStyle(Color.Text.primary)
      }
    }  // VStack
    .frame(
      minWidth: 0,
      idealWidth: imageType.size.width,
      maxWidth: imageType.size.width,
      minHeight: 0,
      idealHeight: imageType.size.height,
      maxHeight: imageType.size.height
    )
    .overlay(
      imageType.shape
        .stroke(Color.Border.placeholder, style: StrokeStyle(lineWidth: 2, dash: [10, 2]))
    )
  }
}

#Preview {
  VStack(spacing: 20) {
    EmptyPhotoSlot(as: .avatar)
    EmptyPhotoSlot(as: .eventThumbnail)
    EmptyPhotoSlot(as: .raceHero)
  }  // VStack
  .padding(40)
  .background(Color.Background.primary)
}

#Preview("Labelled") {
  EmptyPhotoSlot(as: .medal, text: "Add front")
    .padding()
    .background(Color.Background.primary)
}
