//
//  CameraAccess.swift
//  MedalWall
//
//  Created by Quien on 2026-11-12.
//

import AVFoundation
import UIKit

/// What tapping Take Photo leads to, from whether the device has a camera and whether the app
/// may use it.
enum CameraAccess {
  /// The camera can open.
  case granted
  /// The app has not asked for camera access yet, so iOS asks first.
  case undetermined
  /// Camera access is turned off, or restricted by Screen Time; only Settings can turn it on.
  case denied
  /// The device has no camera.
  case unavailable

  /// Maps the device's camera and the app's authorization `status` to what Take Photo does.
  init(hasCamera: Bool, status: AVAuthorizationStatus) {
    guard hasCamera else {
      self = .unavailable
      return
    }

    switch status {
    case .authorized: self = .granted
    case .notDetermined: self = .undetermined
    case .denied, .restricted: self = .denied
    @unknown default: self = .denied
    }
  }

  /// Camera access on this device as it stands now.
  static var current: CameraAccess {
    CameraAccess(
      hasCamera: UIImagePickerController.isSourceTypeAvailable(.camera),
      status: AVCaptureDevice.authorizationStatus(for: .video)
    )
  }
}
