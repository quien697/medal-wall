//
//  PhotoSlotViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-11-14.
//

import ImageIO
import SwiftUI
import Testing
import UniformTypeIdentifiers

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

  // MARK: - Crop
  @Test("a picked photo's data becomes the photo to crop")
  func testPickedPhotoIsCropped() throws {
    let viewModel = makeViewModel(access: .granted)
    let data = try #require(UIImage(systemName: "medal.fill")?.pngData())

    let error = viewModel.cropPickedPhoto(data)

    #expect(error == nil)
    #expect(viewModel.photoToCrop != nil)
  }

  @Test("a large picked photo reaches the crop sheet at its own pixel size, never shrunk")
  func testLargePickedPhotoKeepsPixelSize() throws {
    let viewModel = makeViewModel(access: .granted)
    let data = try #require(
      TestPhotos.plain(width: 4000, height: 3000).jpegData(compressionQuality: 0.8))

    _ = viewModel.cropPickedPhoto(data)

    let photo = try #require(viewModel.photoToCrop?.image)
    #expect(photo.size.width * photo.scale == 4000)
    #expect(photo.size.height * photo.scale == 3000)
  }

  @Test(
    "a picked photo that is not an image crops nothing and is reported",
    arguments: [nil, Data("not an image".utf8)])
  func testUnreadablePickedPhoto(data: Data?) {
    let viewModel = makeViewModel(access: .granted)

    let error = viewModel.cropPickedPhoto(data)

    #expect(error == .photoDataInvalid)
    #expect(viewModel.photoToCrop == nil)
  }

  @Test("a confirmed crop under the upload limit is returned with its checked JPEG")
  func testConfirmedCropUnderLimitIsReturned() async throws {
    let viewModel = makeViewModel(access: .granted)
    let croppedImage = TestPhotos.plain(width: 400, height: 400)

    let photo = try await viewModel.confirmCrop(croppedImage)

    #expect(photo.image === croppedImage)
    let source = try #require(CGImageSourceCreateWithData(photo.jpegData as CFData, nil))
    #expect(CGImageSourceGetType(source) as String? == UTType.jpeg.identifier)
    #expect(viewModel.error == nil)
  }

  // `MedalWall.` names the app's `AppError`, which the app's `PhotoSlotViewModel` throws: the
  // test target compiles its own copy for the files on its include list.
  @Test("a confirmed crop over the upload limit is refused, keeping the crop screen open")
  func testConfirmedCropOverLimitIsRefused() async throws {
    let viewModel = makeViewModel(access: .granted)
    let croppedImage = try #require(TestPhotos.noise())

    await #expect(throws: MedalWall.AppError.croppedPhotoTooLarge) {
      try await viewModel.confirmCrop(croppedImage)
    }
    #expect(viewModel.error == .croppedPhotoTooLarge)
  }

  @Test("a crop the crop screen couldn't render is refused as invalid photo data")
  func testMissingCropIsRefused() async {
    let viewModel = makeViewModel(access: .granted)

    await #expect(throws: MedalWall.AppError.photoDataInvalid) {
      try await viewModel.confirmCrop(nil)
    }
    #expect(viewModel.error == .photoDataInvalid)
  }

  @Test("a photo taken reaches the crop sheet once the camera closes")
  func testTakenPhotoIsCroppedWhenCameraCloses() {
    let viewModel = makeViewModel(access: .granted)
    let takenPhoto = UIImage()
    viewModel.takenPhoto = takenPhoto

    viewModel.cameraDidClose()

    #expect(viewModel.photoToCrop?.image === takenPhoto)
    #expect(viewModel.takenPhoto == nil)
  }

  @Test("closing the camera without taking a photo crops nothing")
  func testClosingCameraWithoutPhotoCropsNothing() {
    let viewModel = makeViewModel(access: .granted)

    viewModel.cameraDidClose()

    #expect(viewModel.photoToCrop == nil)
  }

  // MARK: - Content
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
  // `MedalWall.` names the app's `PhotoSlotContent`, which `PhotoSlotViewModel` takes: the test
  // target compiles its own copy for the view models on its include list.
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
    arguments: [MedalWall.PhotoSlotContent.photo(UIImage()), .loading, .failed])
  func testSlotHoldingPhotoReadsTitle(content: MedalWall.PhotoSlotContent) {
    let label = PhotoSlotViewModel.accessibilityLabel(
      content: content, title: "Front photo", placeholderText: "Add front")

    #expect(label == "Front photo")
  }
}
