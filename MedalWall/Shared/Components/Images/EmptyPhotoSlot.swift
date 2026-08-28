//
//  EmptyPhotoSlot.swift
//  MedalWall
//
//  Created by Quien on 2026-08-28.
//

import SwiftUI

/// An empty slot inviting a photo.
///
/// The dashed edge on a clear ground is reserved for this one placeholder, because it
/// is the only one that is an affordance — everything else missing uses
/// `PlaceholderImage`.
struct EmptyPhotoSlot: View {
  private let imageType: ImageType

  init(as imageType: ImageType) {
    self.imageType = imageType
  }

  var body: some View {
    Image(systemName: "plus")
      .resizable()
      .scaledToFit()
      .frame(width: imageType.size.width * 0.2)
      .foregroundStyle(Color.Text.secondary)
      .frame(width: imageType.size.width, height: imageType.size.height)
      .overlay(
        imageType.shape
          .stroke(Color.Pigment.pewter, style: StrokeStyle(lineWidth: 2, dash: [10, 2]))
      )
  }
}

#Preview {
  VStack(spacing: 20) {
    EmptyPhotoSlot(as: .avatar)
    EmptyPhotoSlot(as: .medal)
    EmptyPhotoSlot(as: .event)
    EmptyPhotoSlot(as: .raceHero)
  }  // HStack
  .padding(40)
  .background(Color.Background.primary)
}
