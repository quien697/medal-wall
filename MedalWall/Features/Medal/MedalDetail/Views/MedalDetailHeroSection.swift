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
/// The medal is one button: tapping anywhere on it turns it over, to an empty face's
/// placeholder too.
///
/// Lays itself out rather than going through `DetailHeroSection`, which sets a photo beside
/// leading-aligned text — the shape `RaceDetailHeroSection` still wants and this one no
/// longer does.
struct MedalDetailHeroSection: View {
  // MARK: - Properties
  let frontPhotoUrl: String?
  let backPhotoUrl: String?
  let faceInView: MedalFace
  let flipHint: LocalizedStringKey
  let name: String
  let onToggleFace: () -> Void

  // MARK: - Body
  var body: some View {
    VStack(spacing: .Space.row) {
      Button(action: onToggleFace) {
        MedalFlipImage(
          frontPhotoUrl: frontPhotoUrl,
          backPhotoUrl: backPhotoUrl,
          faceInView: faceInView
        )
      }  // Button
      .buttonStyle(.plain)
      .accessibilityLabel(Text(faceInView.title))
      .accessibilityHint(flipHint)

      Text(name)
        .font(.TypeScale.title1)
        .foregroundStyle(Color.Text.primary)
        .multilineTextAlignment(.center)
        .fixedSize(horizontal: false, vertical: true)
    }  // VStack
    .frame(maxWidth: .infinity)
    .padding(.horizontal, .Space.gutter)
    .padding(.vertical, .Space.panel)
  }
}

#Preview("Both faces") {
  @Previewable @State var faceInView: MedalFace = .front

  MedalDetailHeroSection(
    frontPhotoUrl: nil, backPhotoUrl: "preview-back", faceInView: faceInView,
    flipHint: faceInView == .front ? "Shows the back" : "Shows the front",
    name: "Taipei Marathon 2019",
    onToggleFace: { faceInView = faceInView == .front ? .back : .front }
  )
  .background(Color.Background.primary)
}

#Preview("No photos") {
  @Previewable @State var faceInView: MedalFace = .front

  MedalDetailHeroSection(
    frontPhotoUrl: nil, backPhotoUrl: nil, faceInView: faceInView,
    flipHint: faceInView == .front ? "Shows the back" : "Shows the front",
    name: "BMO Vancouver Marathon Half Marathon 2022",
    onToggleFace: { faceInView = faceInView == .front ? .back : .front }
  )
  .background(Color.Background.primary)
}
