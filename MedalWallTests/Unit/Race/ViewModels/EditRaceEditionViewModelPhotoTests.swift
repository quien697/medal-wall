//
//  EditRaceEditionViewModelPhotoTests.swift
//  MedalWall
//
//  Created by Quien on 2026-11-15.
//

import Testing
import UIKit

@testable import MedalWall

/// Covers the status of an edition's stored photo while the form downloads it.
struct EditRaceEditionViewModelPhotoTests {
  private func makeStoredEdition(photoUrl: String?) -> DraftRaceEdition {
    var staged = DraftRaceEdition(from: .taipei2025)
    staged.existingPhotoUrl = photoUrl
    return staged
  }

  @Test("a stored edition photo is loading until it downloads")
  func testStoredEditionPhotoLoads() async throws {
    let viewModel = EditRaceEditionViewModel(
      mode: .edit, draft: makeStoredEdition(photoUrl: try makeStoredPhotoFile()))
    #expect(viewModel.storedPhotoStatus == .loading)

    await viewModel.loadExistingPhoto()

    #expect(viewModel.storedPhotoStatus == nil)
    #expect(viewModel.photo != nil)
  }

  @Test("a stored edition photo that can't be downloaded is marked failed")
  func testStoredEditionPhotoFails() async {
    let viewModel = EditRaceEditionViewModel(
      mode: .edit, draft: makeStoredEdition(photoUrl: "file:///nonexistent/stored-photo.jpg"))

    await viewModel.loadExistingPhoto()

    #expect(viewModel.storedPhotoStatus == .failed)
  }

  @Test("an edition with no stored photo, or a newly picked one, has no status")
  func testNoStoredEditionPhoto() throws {
    var picked = makeStoredEdition(photoUrl: "file:///nonexistent/stored-photo.jpg")
    picked.newPhotoData = try #require(UIImage(systemName: "photo")?.pngData())

    #expect(EditRaceEditionViewModel(mode: .add, draft: nil).storedPhotoStatus == nil)
    #expect(
      EditRaceEditionViewModel(mode: .edit, draft: makeStoredEdition(photoUrl: nil))
        .storedPhotoStatus == nil)
    #expect(EditRaceEditionViewModel(mode: .edit, draft: picked).storedPhotoStatus == nil)
  }

  @Test("picking or removing a photo ends the stored photo's status", arguments: [true, false])
  func testChangingEditionPhotoEndsStatus(picks: Bool) async {
    let viewModel = EditRaceEditionViewModel(
      mode: .edit, draft: makeStoredEdition(photoUrl: "file:///nonexistent/stored-photo.jpg"))
    await viewModel.loadExistingPhoto()

    if picks {
      viewModel.updatePhoto(with: UIImage())
    } else {
      viewModel.clearPhoto()
    }

    #expect(viewModel.storedPhotoStatus == nil)
  }

  /// A file URL holding a 1 × 1 PNG, for the form to download as its stored photo.
  private func makeStoredPhotoFile() throws -> String {
    let image = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { _ in }
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("\(UUID().uuidString).png")
    try #require(image.pngData()).write(to: url)
    return url.absoluteString
  }
}
