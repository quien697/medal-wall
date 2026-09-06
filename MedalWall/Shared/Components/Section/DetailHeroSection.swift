//
//  DetailHeroSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-06.
//

import SwiftUI

/// A reusable layout container for detail screen heros.
/// Renders an image slot on the left and an info content slot on the right,
struct DetailHeroSection<ImageContent: View, InfoContent: View>: View {
  private let imageContent: ImageContent
  private let infoContent: InfoContent

  init(
    @ViewBuilder imageContent: () -> ImageContent,
    @ViewBuilder infoContent: () -> InfoContent
  ) {
    self.imageContent = imageContent()
    self.infoContent = infoContent()
  }

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      imageContent

      VStack(alignment: .leading, spacing: 8) {
        infoContent
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(.vertical, 30)
    .padding(.horizontal)
    .frame(maxWidth: .infinity)
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(Color.Border.primary)
        .frame(height: 1)
    }
  }
}

#Preview {
  ScrollView {
    DetailHeroSection {
      PlaceholderImage(as: .raceHero)
    } infoContent: {
      Text("Race Name")
        .font(.title2)
        .fontWeight(.bold)
        .foregroundStyle(Color.Text.primary)

      Text("Taipei, Taiwan")
        .font(.subheadline)
        .foregroundStyle(Color.Text.tertiary)
    }
  }
  .background(Color.Background.primary)
}
