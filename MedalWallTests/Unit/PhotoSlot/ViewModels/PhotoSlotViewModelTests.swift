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

  @Test("a cropped photo whose JPEG is over the upload limit is refused as too large")
  func testCroppedPhotoOverLimitIsRefused() async throws {
    let viewModel = makeViewModel(access: .granted)
    let crop = viewModel.beginCrop()
    let croppedPhoto = try #require(TestPhotos.noise())

    let outcome = await viewModel.checkCroppedPhoto(croppedPhoto, crop: crop)

    guard case .refused(let error) = outcome else {
      Issue.record("expected the photo to be refused, got \(outcome)")
      return
    }
    #expect(error == .photoTooLarge)
  }

  @Test("a cropped photo under the upload limit is handed over with its checked JPEG")
  func testCroppedPhotoUnderLimitIsUsable() async throws {
    let viewModel = makeViewModel(access: .granted)
    let crop = viewModel.beginCrop()
    let croppedPhoto = TestPhotos.plain(width: 400, height: 400)

    let outcome = await viewModel.checkCroppedPhoto(croppedPhoto, crop: crop)

    guard case .usable(let photo) = outcome else {
      Issue.record("expected the photo to be usable, got \(outcome)")
      return
    }
    #expect(photo.image === croppedPhoto)
    let source = try #require(CGImageSourceCreateWithData(photo.jpegData as CFData, nil))
    #expect(CGImageSourceGetType(source) as String? == UTType.jpeg.identifier)
  }

  @Test("a crop confirmed before a newer one is never applied, whichever check ends first")
  func testOlderCropIsSuperseded() async {
    let viewModel = makeViewModel(access: .granted)
    let older = viewModel.beginCrop()
    let newer = viewModel.beginCrop()
    let croppedPhoto = TestPhotos.plain(width: 400, height: 400)

    let newerOutcome = await viewModel.checkCroppedPhoto(croppedPhoto, crop: newer)
    let olderOutcome = await viewModel.checkCroppedPhoto(croppedPhoto, crop: older)

    guard case .usable = newerOutcome else {
      Issue.record("expected the newer crop to be used, got \(newerOutcome)")
      return
    }
    guard case .superseded = olderOutcome else {
      Issue.record("expected the older crop to be superseded, got \(olderOutcome)")
      return
    }
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
