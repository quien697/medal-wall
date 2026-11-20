//
//  PhotoSlotViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-11-14.
//

import AVFoundation
import SwiftUI

@Observable
@MainActor
final class PhotoSlotViewModel {
  // MARK: - State
  var isPresentingCamera = false
  var isPresentingCameraSettings = false
  var isPresentingNoCamera = false
  /// The photo the camera handed back, sent to the crop sheet once the camera has closed.
  var takenPhoto: UIImage?
  /// The photo picked or taken, waiting in the crop sheet.
  var photoToCrop: PickedPhoto?

  /// Numbers each confirmed crop, so a check that ends after a newer crop is ignored.
  @ObservationIgnored private var crops = LoadSequence()

  /// iOS's camera access prompt while it is up. Exposed so tests can await it.
  @ObservationIgnored private(set) var cameraAccessRequest: Task<Void, Never>?

  // MARK: - Dependencies
  private let currentCameraAccess: @MainActor () -> CameraAccess
  private let requestCameraAccess: @MainActor () async -> Bool

  // MARK: - Init
  /// The device reads are built here rather than as default arguments: default expressions are
  /// evaluated in a nonisolated context, which cannot read the `@MainActor` camera state.
  init(
    currentCameraAccess: (@MainActor () -> CameraAccess)? = nil,
    requestCameraAccess: (@MainActor () async -> Bool)? = nil
  ) {
    self.currentCameraAccess = currentCameraAccess ?? { CameraAccess.current }
    self.requestCameraAccess =
      requestCameraAccess ?? { await AVCaptureDevice.requestAccess(for: .video) }
  }

  // MARK: - Functions
  /// Opens the camera when camera access allows it, lets iOS ask first when it has not asked
  /// yet, and otherwise presents why the camera cannot open.
  func takePhoto() {
    switch currentCameraAccess() {
    case .granted:
      isPresentingCamera = true
    case .undetermined:
      cameraAccessRequest = Task { [weak self] in
        guard let self else { return }
        if await requestCameraAccess() {
          isPresentingCamera = true
        }
      }
    case .denied:
      isPresentingCameraSettings = true
    case .unavailable:
      isPresentingNoCamera = true
    }
  }

  /// Hands a photo picked from the library to the crop sheet, or returns the error to show when
  /// its data is not an image.
  func cropPickedPhoto(_ data: Data?) -> AppError? {
    guard let data, let image = UIImage(data: data) else { return .photoDataInvalid }
    photoToCrop = PickedPhoto(image: image)
    return nil
  }

  /// What to do with a cropped photo once its size check ends.
  enum CropOutcome {
    /// The photo, checked, ready to hand to the form.
    case usable(CroppedPhoto)
    /// Storage would refuse the photo; show the error and leave the slot as it is.
    case refused(AppError)
    /// A newer crop was confirmed during the check, so this photo is not used.
    case superseded
  }

  /// Numbers a crop the user has just confirmed, so only the newest one is used.
  func beginCrop() -> Int {
    crops.begin()
  }

  /// Encodes and checks the image of `crop`.
  func checkCroppedPhoto(_ image: UIImage, crop: Int) async -> CropOutcome {
    let result = await Self.croppedPhoto(from: image)
    guard crops.isNewest(crop) else { return .superseded }
    switch result {
    case .success(let photo): return .usable(photo)
    case .failure(let error): return .refused(error)
    }
  }

  /// `image` encoded and checked as a `CroppedPhoto`. Runs off the main actor, since encoding a
  /// full-resolution crop takes a noticeable moment.
  @concurrent
  nonisolated private static func croppedPhoto(from image: UIImage) async -> Result<
    CroppedPhoto, AppError
  > {
    do throws(AppError) {
      return .success(try CroppedPhoto(checking: image))
    } catch {
      return .failure(error)
    }
  }

  /// Hands the photo taken to the crop sheet once the camera has closed; closing it without one
  /// crops nothing.
  func cameraDidClose() {
    if let takenPhoto {
      photoToCrop = PickedPhoto(image: takenPhoto)
    }
    takenPhoto = nil
  }

  /// What VoiceOver reads for a slot: its placeholder text while it is empty, if it has one,
  /// and otherwise its title.
  static func accessibilityLabel(
    content: PhotoSlotContent, title: LocalizedStringKey, placeholderText: LocalizedStringKey?
  ) -> LocalizedStringKey {
    guard content == .empty, let placeholderText else { return title }
    return placeholderText
  }
}
