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
  /// Why the crop just confirmed was refused, shown over the crop screen.
  var error: AppError?

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

  /// The crop the user confirmed, encoded once as the JPEG to upload and checked. A crop the
  /// crop screen couldn't render (`.photoDataInvalid`), or whose JPEG Storage would refuse
  /// (`.croppedPhotoTooLarge`), is refused: the error is kept to show over the crop screen,
  /// and thrown so the crop screen stays open.
  func confirmCrop(_ croppedImage: UIImage?) async throws(AppError) -> CroppedPhoto {
    do throws(AppError) {
      guard let croppedImage else { throw .photoDataInvalid }
      return try await Self.croppedPhoto(from: croppedImage)
    } catch {
      self.error = error
      throw error
    }
  }

  /// `image` encoded and checked as a `CroppedPhoto`. Runs off the main actor, so the crop
  /// screen's progress keeps turning while a full-resolution crop is encoded.
  @concurrent
  nonisolated private static func croppedPhoto(from image: UIImage) async throws(AppError)
    -> CroppedPhoto
  {
    try CroppedPhoto(checking: image)
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
