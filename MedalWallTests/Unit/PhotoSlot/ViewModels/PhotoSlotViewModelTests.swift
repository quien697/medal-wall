//
//  PhotoSlotViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-11-14.
//

import SwiftUI
import Testing

@testable import MedalWall

/// Covers what tapping Take Photo presents for each kind of camera access, and what VoiceOver
/// reads for a slot.
@MainActor
struct PhotoSlotViewModelTests {

  // MARK: - Helpers
  /// Records whether iOS was asked for camera access.
  private final class AskRecorder {
    var wasAsked = false
  }

  private func makeViewModel(
    access: CameraAccess,
    allowsWhenAsked: Bool = false,
    recorder: AskRecorder = AskRecorder()
  ) -> PhotoSlotViewModel {
    PhotoSlotViewModel(
      currentCameraAccess: { access },
      requestCameraAccess: {
        recorder.wasAsked = true
        return allowsWhenAsked
      }
    )
  }

  // MARK: - Take Photo
  @Test("with camera access granted, Take Photo opens the camera")
  func testGrantedOpensCamera() {
    let viewModel = makeViewModel(access: .granted)

    viewModel.takePhoto()

    #expect(viewModel.isPresentingCamera)
    #expect(!viewModel.isPresentingCameraSettings)
    #expect(!viewModel.isPresentingNoCamera)
  }

  @Test("before iOS has asked, Take Photo opens the camera only once the user allows it")
  func testUndeterminedAllowedOpensCamera() async {
    let viewModel = makeViewModel(access: .undetermined, allowsWhenAsked: true)

    viewModel.takePhoto()
    #expect(!viewModel.isPresentingCamera)

    await viewModel.cameraAccessRequest?.value
    #expect(viewModel.isPresentingCamera)
  }

  @Test("before iOS has asked, Take Photo presents nothing when the user refuses")
  func testUndeterminedRefusedPresentsNothing() async {
    let recorder = AskRecorder()
    let viewModel = makeViewModel(access: .undetermined, recorder: recorder)

    viewModel.takePhoto()
    await viewModel.cameraAccessRequest?.value

    #expect(recorder.wasAsked)
    #expect(!viewModel.isPresentingCamera)
    #expect(!viewModel.isPresentingCameraSettings)
    #expect(!viewModel.isPresentingNoCamera)
  }

  @Test("with camera access off, Take Photo points to Settings")
  func testDeniedPointsToSettings() {
    let viewModel = makeViewModel(access: .denied)

    viewModel.takePhoto()

    #expect(viewModel.isPresentingCameraSettings)
    #expect(!viewModel.isPresentingCamera)
    #expect(!viewModel.isPresentingNoCamera)
  }

  @Test("on a device without a camera, Take Photo says there is none")
  func testUnavailableSaysNoCamera() {
    let viewModel = makeViewModel(access: .unavailable)

    viewModel.takePhoto()

    #expect(viewModel.isPresentingNoCamera)
    #expect(!viewModel.isPresentingCamera)
    #expect(!viewModel.isPresentingCameraSettings)
  }

  @Test(
    "once iOS has asked, or with no camera, Take Photo never asks again",
    arguments: [CameraAccess.granted, .denied, .unavailable])
  func testDecidedAccessNeverAsks(access: CameraAccess) async {
    let recorder = AskRecorder()
    let viewModel = makeViewModel(access: access, recorder: recorder)

    viewModel.takePhoto()
    await viewModel.cameraAccessRequest?.value

    #expect(!recorder.wasAsked)
  }

  // MARK: - Accessibility label
  @Test("an empty slot reads its placeholder text")
  func testEmptySlotReadsPlaceholderText() {
    let label = PhotoSlotViewModel.accessibilityLabel(
      photo: nil, title: "Front photo", placeholderText: "Add front")

    #expect(label == "Add front")
  }

  @Test("an empty slot with no placeholder text reads its title")
  func testEmptySlotWithoutPlaceholderReadsTitle() {
    let label = PhotoSlotViewModel.accessibilityLabel(
      photo: nil, title: "Front photo", placeholderText: nil)

    #expect(label == "Front photo")
  }

  @Test("a filled slot reads its title")
  func testFilledSlotReadsTitle() {
    let label = PhotoSlotViewModel.accessibilityLabel(
      photo: UIImage(), title: "Front photo", placeholderText: "Add front")

    #expect(label == "Front photo")
  }
}
