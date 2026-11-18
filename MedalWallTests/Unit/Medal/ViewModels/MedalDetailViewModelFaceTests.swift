//
//  MedalDetailViewModelFaceTests.swift
//  MedalWall
//
//  Created by Quien on 2026-11-03.
//

import Foundation
import SwiftUI
import Testing

@testable import MedalWall

/// Covers which face the details show and how tapping the medal turns it over.
@MainActor
struct MedalDetailViewModelFaceTests {

  private func makeMedal(frontPhotoUrl: String?, backPhotoUrl: String?) -> Medal {
    Medal(
      name: "Test",
      date: .now,
      bibNumber: "1",
      photoUrls: MedalPhotoUrls(front: frontPhotoUrl, back: backPhotoUrl),
      place: Place(countryCode: "CA", city: "Vancouver"),
      raceEvent: RaceEvent(category: .full, type: .inPerson),
      userID: "u1"
    )
  }

  @Test("the details open on the front")
  func testOpensOnTheFront() {
    let viewModel = MedalDetailViewModel(
      medal: makeMedal(frontPhotoUrl: "front.png", backPhotoUrl: "back.png"))

    #expect(viewModel.faceInView == .front)
    #expect(viewModel.faceInView.title == "Front")
  }

  @Test("flipping turns the medal to its other face and back again")
  func testToggleFace() {
    let viewModel = MedalDetailViewModel(
      medal: makeMedal(frontPhotoUrl: "front.png", backPhotoUrl: "back.png"))

    viewModel.toggleFace()
    #expect(viewModel.faceInView == .back)
    #expect(viewModel.flipHint == "Shows the front")

    viewModel.toggleFace()
    #expect(viewModel.faceInView == .front)
    #expect(viewModel.flipHint == "Shows the back")
  }

  @Test("a medal with no back still flips, to the back's placeholder")
  func testFlipsWithoutBack() {
    let viewModel = MedalDetailViewModel(
      medal: makeMedal(frontPhotoUrl: "front.png", backPhotoUrl: nil))

    viewModel.toggleFace()
    #expect(viewModel.faceInView == .back)

    viewModel.toggleFace()
    #expect(viewModel.faceInView == .front)
  }

  @Test("a back removed by a reload leaves the back in view, as its placeholder")
  func testRemovedBackKeepsTheFace() {
    let viewModel = MedalDetailViewModel(
      medal: makeMedal(frontPhotoUrl: "front.png", backPhotoUrl: "back.png"))
    viewModel.toggleFace()

    viewModel.medal.photoUrls?.back = nil

    #expect(viewModel.faceInView == .back)
  }

  @Test("the front is shown at no turn and the back at a half turn")
  func testFlipAngle() {
    #expect(MedalDetailViewModel.flipAngle(showing: .front) == 0)
    #expect(MedalDetailViewModel.flipAngle(showing: .back) == 180)
  }

  @Test("the medal turns over to show its back, and never turns under Reduce Motion")
  func testRotation() {
    #expect(MedalDetailViewModel.rotation(showing: .front, turns: true) == 0)
    #expect(MedalDetailViewModel.rotation(showing: .back, turns: true) == 180)
    #expect(MedalDetailViewModel.rotation(showing: .front, turns: false) == 0)
    #expect(MedalDetailViewModel.rotation(showing: .back, turns: false) == 0)
  }

  @Test(
    "while the medal turns, the front shows until it is edge-on, and the back after",
    arguments: [(0.0, 1.0, 0.0), (89.0, 1.0, 0.0), (91.0, 0.0, 1.0), (180.0, 0.0, 1.0)])
  func testOpacityWhileTurning(flipAngle: Double, front: Double, back: Double) {
    #expect(MedalDetailViewModel.faceOpacity(.front, flipAngle: flipAngle, turns: true) == front)
    #expect(MedalDetailViewModel.faceOpacity(.back, flipAngle: flipAngle, turns: true) == back)
  }

  @Test(
    "under Reduce Motion, the faces crossfade",
    arguments: [(0.0, 1.0, 0.0), (90.0, 0.5, 0.5), (180.0, 0.0, 1.0)])
  func testOpacityUnderReduceMotion(flipAngle: Double, front: Double, back: Double) {
    #expect(MedalDetailViewModel.faceOpacity(.front, flipAngle: flipAngle, turns: false) == front)
    #expect(MedalDetailViewModel.faceOpacity(.back, flipAngle: flipAngle, turns: false) == back)
  }

  /// States the token values: `Animation.Motion` compiles into both the app and this test
  /// module, so naming it here is ambiguous.
  @Test("the medal turns over with motion.flip, and fades under Reduce Motion")
  func testFlipAnimation() {
    #expect(
      MedalDetailViewModel.flipAnimation(turns: true)
        == .spring(response: 0.45, dampingFraction: 0.78))
    #expect(MedalDetailViewModel.flipAnimation(turns: false) == .easeInOut(duration: 0.2))
  }
}
