//
//  DraftEventPhotoTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-29.
//

import Testing
import UIKit

@testable import MedalWall

struct DraftEventPhotoTests {

  // MARK: - isNew
  @Test("isNew is false when initialized with a URL")
  func testIsNewFalseWhenInitializedWithUrl() {
    let photo = DraftEventPhoto(imageUrl: "https://example.com/photo.jpg")

    #expect(photo.isNew == false)
  }

  @Test("isNew is true when initialized with data")
  func testIsNewTrueWhenInitializedWithData() {
    let data = Data([0xFF, 0xD8, 0xFF])
    let photo = DraftEventPhoto(data: data)

    #expect(photo.isNew == true)
  }

  // MARK: - image
  @Test("image is nil when initialized with a URL")
  func testImageNilWhenInitializedWithUrl() {
    let photo = DraftEventPhoto(imageUrl: "https://example.com/photo.jpg")

    #expect(photo.image == nil)
  }

  @Test("image is returned when data is valid JPEG")
  func testImageReturnedWhenDataIsValidJpeg() {
    let uiImage = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { context in
      UIColor.red.setFill()
      context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    guard let jpegData = uiImage.jpegData(compressionQuality: 1.0) else {
      Issue.record("Failed to create JPEG data from UIImage")
      return
    }
    let photo = DraftEventPhoto(data: jpegData)

    #expect(photo.image != nil)
  }

  @Test("image is nil when data does not represent a valid image")
  func testImageNilWhenDataIsInvalid() {
    let photo = DraftEventPhoto(data: Data([0x00, 0x01, 0x02]))

    #expect(photo.image == nil)
  }

  // MARK: - imageUrl
  @Test("imageUrl is nil when initialized with data")
  func testImageUrlNilWhenInitializedWithData() {
    let data = Data([0xFF, 0xD8, 0xFF])
    let photo = DraftEventPhoto(data: data)

    #expect(photo.imageUrl == nil)
  }
}
