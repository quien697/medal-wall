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
    staged.storedPhotoUrl = photoUrl
    return staged
  }

  @Test("a stored edition photo is loading until it downloads")
  func testStoredEditionPhotoLoads() async throws {
    let viewModel = EditRaceEditionViewModel(
      mode: .edit, draft: makeStoredEdition(photoUrl: try makeStoredPhotoFile()))
    #expect(viewModel.photo.content == .loading)

    await viewModel.loadStoredPhoto()

    #expect(viewModel.photo.content.shownPhoto != nil)
  }

  @Test("a stored edition photo that can't be downloaded is marked failed")
  func testStoredEditionPhotoFails() async {
    let viewModel = EditRaceEditionViewModel(
      mode: .edit, draft: makeStoredEdition(photoUrl: "file:///nonexistent/stored-photo.jpg"))

    await viewModel.loadStoredPhoto()

    #expect(viewModel.photo.content == .failed)
  }

  @Test("an edition with no stored photo is empty, and one with a newly picked photo shows it")
  func testNoStoredEditionPhoto() throws {
    var picked = makeStoredEdition(photoUrl: "file:///nonexistent/stored-photo.jpg")
    let pickedPhoto = try TestPhotos.cropped()
    picked.newPhoto = pickedPhoto

    #expect(EditRaceEditionViewModel(mode: .add, draft: nil).photo.content == .empty)
    #expect(
      EditRaceEditionViewModel(mode: .edit, draft: makeStoredEdition(photoUrl: nil))
        .photo.content == .empty)
    #expect(
      EditRaceEditionViewModel(mode: .edit, draft: picked).photo.content.shownPhoto
        === pickedPhoto.image)
  }

  @Test("picking or removing a photo ends the stored photo's status", arguments: [true, false])
  func testChangingEditionPhotoEndsStatus(picks: Bool) async throws {
    let viewModel = EditRaceEditionViewModel(
      mode: .edit, draft: makeStoredEdition(photoUrl: "file:///nonexistent/stored-photo.jpg"))
    await viewModel.loadStoredPhoto()

    if picks {
      viewModel.photo.update(with: try TestPhotos.cropped())
    } else {
      viewModel.photo.remove()
    }

    #expect(picks ? viewModel.photo.content.shownPhoto != nil : viewModel.photo.content == .empty)
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
