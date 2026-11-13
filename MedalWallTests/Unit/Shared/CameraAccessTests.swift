//
//  CameraAccessTests.swift
//  MedalWall
//
//  Created by Quien on 2026-11-12.
//

import AVFoundation
import Testing

@testable import MedalWall

/// Covers what tapping Take Photo leads to, from whether the device has a camera and whether
/// the app may use it.
@MainActor
struct CameraAccessTests {

  @Test(
    "without a camera, access is unavailable whatever the authorization",
    arguments: [AVAuthorizationStatus.authorized, .notDetermined, .denied, .restricted])
  func testNoCameraIsUnavailable(status: AVAuthorizationStatus) {
    let access = CameraAccess(hasCamera: false, status: status)

    #expect(access == .unavailable)
  }

  @Test("with a camera, an authorized app may open it")
  func testAuthorizedIsGranted() {
    let access = CameraAccess(hasCamera: true, status: .authorized)

    #expect(access == .granted)
  }

  @Test("with a camera, an app that has not asked yet must ask first")
  func testNotDeterminedIsUndetermined() {
    let access = CameraAccess(hasCamera: true, status: .notDetermined)

    #expect(access == .undetermined)
  }

  @Test(
    "with a camera, access turned off or restricted is denied",
    arguments: [AVAuthorizationStatus.denied, .restricted])
  func testDeniedOrRestrictedIsDenied(status: AVAuthorizationStatus) {
    let access = CameraAccess(hasCamera: true, status: status)

    #expect(access == .denied)
  }
}
