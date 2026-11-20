//
//  DraftPhotoTests.swift
//  MedalWall
//
//  Created by Quien on 2026-11-20.
//

import Testing
import UIKit

@testable import MedalWall

/// Covers a form's photo while it is edited: what its slot shows, what save uploads, and
/// whether it is a change.
struct DraftPhotoTests {
  private let storedPhotoUrl = "https://example.com/stored-photo.jpg"

  // MARK: - Init
  @Test("a photo with a stored copy is loading it, and one without is empty")
  func testInitialContent() {
    #expect(DraftPhoto(storedPhotoUrl: storedPhotoUrl).content == .loading)
    #expect(DraftPhoto().content == .empty)
  }

  @Test("a photo staged in an earlier session is shown and uploaded, and is not a change")
  func testStagedPhoto() throws {
    let staged = try TestPhotos.cropped()

    let photo = DraftPhoto(staged: staged)

    #expect(photo.content.shownPhoto === staged.image)
    #expect(photo.croppedPhoto?.jpegData == staged.jpegData)
    #expect(!photo.isChanged)
  }

  // MARK: - Changes
  @Test("a cropped photo is shown in place of the stored photo's status and staged for save")
  func testUpdate() throws {
    var photo = DraftPhoto(storedPhotoUrl: storedPhotoUrl)
    let cropped = try TestPhotos.cropped()

    photo.update(with: cropped)

    #expect(photo.content.shownPhoto === cropped.image)
    #expect(photo.croppedPhoto?.jpegData == cropped.jpegData)
    #expect(photo.isChanged)
  }

  @Test("a removed photo leaves the slot empty, with nothing to upload")
  func testRemove() throws {
    var photo = DraftPhoto(storedPhotoUrl: storedPhotoUrl)
    photo.update(with: try TestPhotos.cropped())

    photo.remove()

    #expect(photo.content == .empty)
    #expect(photo.croppedPhoto == nil)
    #expect(photo.isChanged)
  }

  // MARK: - Stored photo
  @Test("a downloaded stored photo is shown")
  func testStoredPhotoShown() {
    var photo = DraftPhoto(storedPhotoUrl: storedPhotoUrl)
    let downloaded = TestPhotos.plain(width: 1, height: 1)

    photo.showStored(downloaded)

    #expect(photo.content.shownPhoto === downloaded)
    #expect(!photo.isChanged)
  }

  @Test("a stored photo that couldn't download is marked failed")
  func testStoredPhotoFailed() {
    var photo = DraftPhoto(storedPhotoUrl: storedPhotoUrl)

    photo.showStored(nil)

    #expect(photo.content == .failed)
  }

  @Test("a download that fails keeps a stored photo already shown")
  func testFailedDownloadKeepsShownPhoto() {
    var photo = DraftPhoto(storedPhotoUrl: storedPhotoUrl)
    let downloaded = TestPhotos.plain(width: 1, height: 1)
    photo.showStored(downloaded)

    photo.showStored(nil)

    #expect(photo.content.shownPhoto === downloaded)
  }

  @Test(
    "a stored photo that downloads after a photo was cropped or removed changes nothing",
    arguments: [true, false])
  func testStoredPhotoAfterChange(crops: Bool) throws {
    var photo = DraftPhoto(storedPhotoUrl: storedPhotoUrl)
    let cropped = try TestPhotos.cropped()
    if crops {
      photo.update(with: cropped)
    } else {
      photo.remove()
    }

    photo.showStored(TestPhotos.plain(width: 1, height: 1))

    #expect(photo.content.shownPhoto === (crops ? cropped.image : nil))
    #expect(photo.content.holdsPhoto == crops)
  }

  // MARK: - Save
  @Test("a saved photo is no longer a change, and is still shown and staged")
  func testMarkSaved() throws {
    var photo = DraftPhoto(storedPhotoUrl: storedPhotoUrl)
    let cropped = try TestPhotos.cropped()
    photo.update(with: cropped)

    photo.markSaved()

    #expect(!photo.isChanged)
    #expect(photo.content.shownPhoto === cropped.image)
    #expect(photo.croppedPhoto?.jpegData == cropped.jpegData)
  }
}
