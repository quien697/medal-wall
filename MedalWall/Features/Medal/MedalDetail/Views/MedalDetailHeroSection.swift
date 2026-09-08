//
//  MedalDetailHeroSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-07.
//

import SwiftUI

/// What the screen opens with: the medal, and the race it came from.
///
/// Nothing else shares the band. Where, when, how far and under which bib are facts about
/// the race rather than the thing on the wall, and they are stated below in a list of
/// their own.
///
/// Lays itself out rather than going through `DetailHeroSection`, which sets a photo beside
/// leading-aligned text — the shape `RaceDetailHeroSection` still wants and this one no
/// longer does.
struct MedalDetailHeroSection: View {
  // MARK: - Properties
  private let titleTracking: CGFloat = -0.8
  let photoUrl: String?
  let name: String

  // MARK: - Body
  var body: some View {
    VStack(spacing: .Space.row) {
      PhotoImage(urlString: photoUrl, as: .medal)
        .medalRing()

      Text(name)
        .font(.TypeScale.title1)
        .tracking(titleTracking)
        .textCase(.uppercase)
        .foregroundStyle(Color.Text.primary)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }  // VStack
    .frame(maxWidth: .infinity)
    .padding(.horizontal, .Space.gutter)
    .padding(.vertical, .Space.panel)
  }
}

#Preview("Short name") {
  MedalDetailHeroSection(photoUrl: nil, name: "Taipei Marathon 2019")
    .background(Color.Background.primary)
}

#Preview("Name that must wrap") {
  MedalDetailHeroSection(
    photoUrl: nil,
    name: "BMO Vancouver Marathon Half Marathon 2022"
  )
  .background(Color.Background.primary)
}
