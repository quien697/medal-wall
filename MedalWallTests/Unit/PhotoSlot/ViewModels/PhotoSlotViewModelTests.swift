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

  // MARK: - Framing
  @Test("a picked photo's data becomes the photo to frame")
  func testPickedPhotoIsFramed() throws {
    let viewModel = makeViewModel(access: .granted)
    let data = try #require(UIImage(systemName: "medal.fill")?.pngData())

    let error = viewModel.framePickedPhoto(data)

    #expect(error == nil)
    #expect(viewModel.photoToCrop != nil)
  }

  @Test(
    "a picked photo that is not an image frames nothing and is reported",
    arguments: [nil, Data("not an image".utf8)])
  func testUnreadablePickedPhoto(data: Data?) {
    let viewModel = makeViewModel(access: .granted)

    let error = viewModel.framePickedPhoto(data)

    #expect(error == .photoDataInvalid)
    #expect(viewModel.photoToCrop == nil)
  }

  @Test("a photo taken is framed once the camera closes")
  func testTakenPhotoIsFramedWhenCameraCloses() {
    let viewModel = makeViewModel(access: .granted)
    let takenPhoto = UIImage()
    viewModel.takenPhoto = takenPhoto

    viewModel.cameraDidClose()

    #expect(viewModel.photoToCrop?.image === takenPhoto)
    #expect(viewModel.takenPhoto == nil)
  }

  @Test("closing the camera without taking a photo frames nothing")
  func testClosingCameraWithoutPhotoFramesNothing() {
    let viewModel = makeViewModel(access: .granted)

    viewModel.cameraDidClose()

    #expect(viewModel.photoToCrop == nil)
  }

  // MARK: - Content
  // `MedalWall.` names the app's `StoredPhotoStatus`, which `PhotoSlotViewModel` takes: the test
  // target compiles its own copy for the view models on its include list.
  @Test(
    "a slot with a photo shows it, whatever its stored photo's status",
    arguments: [nil, MedalWall.StoredPhotoStatus.loading, .failed])
  func testPhotoIsShown(status: MedalWall.StoredPhotoStatus?) {
    let photo = UIImage()

    let content = PhotoSlotViewModel.content(photo: photo, storedPhotoStatus: status)

    #expect(content == .photo(photo))
  }

  @Test("a slot whose stored photo is downloading shows it is loading")
  func testLoadingStoredPhoto() {
    #expect(PhotoSlotViewModel.content(photo: nil, storedPhotoStatus: .loading) == .loading)
  }

  @Test("a slot whose stored photo couldn't download says so")
  func testFailedStoredPhoto() {
    #expect(PhotoSlotViewModel.content(photo: nil, storedPhotoStatus: .failed) == .failed)
  }

  @Test("a slot with no photo and no stored photo is empty")
  func testEmptySlot() {
    #expect(PhotoSlotViewModel.content(photo: nil, storedPhotoStatus: nil) == .empty)
  }

  @Test(
    "every slot but an empty one offers Remove Photo",
    arguments: [
      (PhotoSlotContent.photo(UIImage()), true), (.loading, true), (.failed, true),
      (.empty, false)
    ])
  func testRemovePhotoOffered(content: PhotoSlotContent, offersRemove: Bool) {
    #expect(content.holdsPhoto == offersRemove)
  }

  // MARK: - Accessibility label
  @Test("an empty slot reads its placeholder text")
  func testEmptySlotReadsPlaceholderText() {
    let label = PhotoSlotViewModel.accessibilityLabel(
      content: .empty, title: "Front photo", placeholderText: "Add front")

    #expect(label == "Add front")
  }

  @Test("an empty slot with no placeholder text reads its title")
  func testEmptySlotWithoutPlaceholderReadsTitle() {
    let label = PhotoSlotViewModel.accessibilityLabel(
      content: .empty, title: "Front photo", placeholderText: nil)

    #expect(label == "Front photo")
  }

  @Test(
    "a slot holding a photo, shown or not, reads its title",
    arguments: [PhotoSlotContent.photo(UIImage()), .loading, .failed])
  func testSlotHoldingPhotoReadsTitle(content: PhotoSlotContent) {
    let label = PhotoSlotViewModel.accessibilityLabel(
      content: content, title: "Front photo", placeholderText: "Add front")

    #expect(label == "Front photo")
  }
}
