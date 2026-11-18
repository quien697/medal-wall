//
//  MedalFaceVisibilityViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-11-13.
//

import SwiftUI

/// Shows a face of the details medal only while it faces the viewer.
///
/// While the medal turns, its flip angle is interpolated frame by frame. Animating this
/// modifier's angle alongside it lets each frame ask `MedalDetailViewModel.faceOpacity` how
/// visible the face is at that angle, which a plain opacity change could not.
struct MedalFaceVisibilityViewModifier: ViewModifier, Animatable {
  let face: MedalFace
  let turns: Bool
  /// How far the medal is turned, in degrees: 0 with the front in view, 180 with the back.
  var flipAngle: Double

  var animatableData: Double {
    get { flipAngle }
    set { flipAngle = newValue }
  }

  func body(content: Content) -> some View {
    content
      .opacity(MedalDetailViewModel.faceOpacity(face, flipAngle: flipAngle, turns: turns))
  }
}

extension View {

  /// Shows this view as the medal's `face`, visible only while it faces the viewer with
  /// `faceInView` in view. The faces swap at 90° while the medal `turns`, and crossfade under
  /// Reduce Motion.
  func medalFaceVisibility(_ face: MedalFace, faceInView: MedalFace, turns: Bool) -> some View {
    modifier(
      MedalFaceVisibilityViewModifier(
        face: face,
        turns: turns,
        flipAngle: MedalDetailViewModel.flipAngle(showing: faceInView)
      )
    )
  }
}

#Preview {
  @Previewable @State var faceInView: MedalFace = .front

  ZStack {
    Color.yellow
      .medalFaceVisibility(.front, faceInView: faceInView, turns: false)

    Color.gray
      .medalFaceVisibility(.back, faceInView: faceInView, turns: false)
  }  // ZStack
  .frame(width: 200, height: 200)
  .animation(.easeInOut(duration: 1), value: faceInView)
  .onTapGesture { faceInView = faceInView == .front ? .back : .front }
}
