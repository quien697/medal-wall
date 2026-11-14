//
//  MedalFlipImage.swift
//  MedalWall
//
//  Created by Quien on 2026-11-13.
//

import SwiftUI

/// The details medal: its two faces back to back, turning about the vertical axis with each face
/// showing only while it faces the viewer. Under Reduce Motion the faces crossfade instead.
///
/// A FRONT / BACK label in its corner names the face in view, and an empty face shows its
/// placeholder. The label stays still while the medal turns, so it never mirrors.
struct MedalFlipImage: View {
  @Environment(\.accessibilityReduceMotion) private var reduceMotion

  let frontPhotoUrl: String?
  let backPhotoUrl: String?
  let faceInView: MedalFace

  var body: some View {
    ZStack(alignment: .topTrailing) {
      ZStack {
        PhotoImage(urlString: frontPhotoUrl, as: .medal, placeholderText: MedalFace.front.title)
          .medalFaceVisibility(.front, faceInView: faceInView, turns: !reduceMotion)

        PhotoImage(urlString: backPhotoUrl, as: .medal, placeholderText: MedalFace.back.title)
          .rotation3DEffect(
            .degrees(MedalDetailViewModel.rotation(showing: .back, turns: !reduceMotion)),
            axis: (x: 0, y: 1, z: 0)
          )
          .medalFaceVisibility(.back, faceInView: faceInView, turns: !reduceMotion)
      }  // ZStack
      .rotation3DEffect(
        .degrees(MedalDetailViewModel.rotation(showing: faceInView, turns: !reduceMotion)),
        axis: (x: 0, y: 1, z: 0)
      )
      .animation(MedalDetailViewModel.flipAnimation(turns: !reduceMotion), value: faceInView)

      Text(faceInView.title)
        .textCase(.uppercase)
        .tracking(.Tracking.tag)
        .chipStyle(.primary, font: .TypeScale.overline, vPadding: 4, hPadding: 8)
        .padding(.Space.stack)
    }  // ZStack
    .contentShape(ImageType.medal.shape)
  }
}

#Preview("Both faces") {
  @Previewable @State var faceInView: MedalFace = .front

  MedalFlipImage(frontPhotoUrl: nil, backPhotoUrl: "preview-back", faceInView: faceInView)
    .onTapGesture { faceInView = faceInView == .front ? .back : .front }
    .padding()
    .background(Color.Background.primary)
}

#Preview("Back in view, dark") {
  MedalFlipImage(frontPhotoUrl: nil, backPhotoUrl: nil, faceInView: .back)
    .padding()
    .background(Color.Background.primary)
    .preferredColorScheme(.dark)
}
