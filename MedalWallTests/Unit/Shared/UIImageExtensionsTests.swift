//
//  UIImageExtensionsTests.swift
//  MedalWall
//
//  Created by Quien on 2026-11-19.
//

import ImageIO
import Testing
import UIKit
import UniformTypeIdentifiers

@testable import MedalWall

/// Covers the JPEG every upload is encoded as.
struct UIImageExtensionsTests {

  // MARK: - Helpers
  /// What encoded image data holds: its type, its pixel size, and whether it records a GPS
  /// location.
  private struct EncodedContents {
    let type: String?
    let pixelSize: CGSize
    let hasLocation: Bool
  }

  /// Image data of `type`, `width` × `height` pixels, recording a GPS location when asked.
  private func makeImageData(
    width: CGFloat, height: CGFloat, type: UTType, withLocation: Bool = false
  ) throws -> Data {
    let image = try #require(TestPhotos.plain(width: width, height: height).cgImage)
    let data = NSMutableData()
    let destination = try #require(
      CGImageDestinationCreateWithData(data, type.identifier as CFString, 1, nil))
    var properties: [CFString: Any] = [:]
    if withLocation {
      properties[kCGImagePropertyGPSDictionary] = [
        kCGImagePropertyGPSLatitude: 25.0330,
        kCGImagePropertyGPSLatitudeRef: "N",
        kCGImagePropertyGPSLongitude: 121.5654,
        kCGImagePropertyGPSLongitudeRef: "E"
      ]
    }
    CGImageDestinationAddImage(destination, image, properties as CFDictionary)
    try #require(CGImageDestinationFinalize(destination))
    return data as Data
  }

  private func contents(of data: Data) throws -> EncodedContents {
    let source = try #require(CGImageSourceCreateWithData(data as CFData, nil))
    let properties = try #require(
      CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? [CFString: Any])
    return EncodedContents(
      type: CGImageSourceGetType(source) as String?,
      pixelSize: CGSize(
        width: properties[kCGImagePropertyPixelWidth] as? Int ?? 0,
        height: properties[kCGImagePropertyPixelHeight] as? Int ?? 0
      ),
      hasLocation: properties[kCGImagePropertyGPSDictionary] != nil
    )
  }

  // MARK: - uploadData
  @Test(
    "an upload is a JPEG at the image's own pixel size, never shrunk",
    arguments: [
      (CGSize(width: 4000, height: 3000), CGFloat(1)),
      (CGSize(width: 2000, height: 1500), CGFloat(2))
    ]
  )
  func testUploadDataKeepsPixelSize(pointSize: CGSize, scale: CGFloat) throws {
    let image = TestPhotos.plain(width: pointSize.width, height: pointSize.height, scale: scale)

    let uploaded = try contents(of: try #require(image.uploadData()))

    #expect(uploaded.type == UTType.jpeg.identifier)
    #expect(uploaded.pixelSize == CGSize(width: 4000, height: 3000))
  }

  @Test("a HEIC photo is uploaded as a JPEG")
  func testHEICIsUploadedAsJPEG() throws {
    let heicData = try makeImageData(width: 400, height: 300, type: .heic)
    try #require(try contents(of: heicData).type == UTType.heic.identifier)
    let image = try #require(UIImage(data: heicData))

    let uploaded = try contents(of: try #require(image.uploadData()))

    #expect(uploaded.type == UTType.jpeg.identifier)
  }

  @Test("an upload carries no GPS location from the picked file")
  func testLocationIsNotUploaded() throws {
    let pickedData = try makeImageData(width: 400, height: 300, type: .jpeg, withLocation: true)
    try #require(try contents(of: pickedData).hasLocation)
    let image = try #require(UIImage(data: pickedData))

    let uploaded = try contents(of: try #require(image.uploadData()))

    #expect(!uploaded.hasLocation)
  }

  // MARK: - Upload size limit
  @Test("an upload one byte under 10 MB is accepted")
  func testUploadUnderLimitIsAccepted() throws {
    let data = Data(count: 10 * 1024 * 1024 - 1)

    #expect(try UIImage.checkedUploadSize(data) == data)
  }

  @Test("an upload of exactly 10 MB is refused as too large")
  func testUploadAtLimitIsRefused() {
    #expect(throws: AppError.photoTooLarge) {
      try UIImage.checkedUploadSize(Data(count: 10 * 1024 * 1024))
    }
  }

  @Test("a photo whose JPEG is over 10 MB is refused as too large")
  func testLargePhotoIsRefused() throws {
    let image = try #require(TestPhotos.noise())
    try #require(try #require(image.uploadData()).count > 10 * 1024 * 1024)

    #expect(throws: AppError.photoTooLarge) {
      try image.checkedUploadData()
    }
  }

  @Test("a photo under the limit gives the JPEG to upload")
  func testSmallPhotoGivesItsJPEG() throws {
    let image = TestPhotos.plain(width: 400, height: 300)

    let uploaded = try contents(of: try image.checkedUploadData())

    #expect(uploaded.type == UTType.jpeg.identifier)
    #expect(uploaded.pixelSize == CGSize(width: 400, height: 300))
  }
}
