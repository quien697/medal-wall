//
//  EditMedalViewModelPhotoTests.swift
//  MedalWall
//
//  Created by Quien on 2026-11-03.
//

import Foundation
import Testing
import UIKit

@testable import MedalWall

/// Covers how the medal form stages its front and back: loading the stored faces and staging
/// cropped photos.
@MainActor
struct EditMedalViewModelPhotoTests {

  private let croppedPhoto = TestPhotos.plain(width: 1, height: 1)

  private func makeMedal(frontPhotoUrl: String? = nil, backPhotoUrl: String? = nil) -> Medal {
    Medal(
      id: "medal-taipei",
      name: "Taipei Marathon",
      date: Date(timeIntervalSince1970: 1_577_836_800),
      bibNumber: "00001",
      photoUrls: MedalPhotoUrls(front: frontPhotoUrl, back: backPhotoUrl),
      place: Place(countryCode: "TW", city: "Taipei City"),
      raceEvent: .default,
      userID: "uid"
    )
  }

  private func makeViewModel(medal: Medal? = nil) -> EditMedalViewModel {
    EditMedalViewModel(
      mode: medal == nil ? .add : .edit,
      medal: medal,
      repository: StubMedalRepository(medals: medal.map { [$0] } ?? []),
      storageService: StubPhotoStorage(),
      networkMonitor: StubNetworkMonitor()
    )
  }

  /// A file URL holding a 1 × 1 PNG of `color`, for the form to load as a stored face.
  private func makeStoredPhoto(_ color: UIColor) throws -> String {
    let image = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { context in
      color.setFill()
      context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    let url = FileManager.default.temporaryDirectory
      .appendingPathComponent("\(UUID().uuidString).png")
    try #require(image.pngData()).write(to: url)
    return url.absoluteString
  }

  @Test("loading a medal loads both of its faces")
  func testLoadsBothFaces() async throws {
    let medal = makeMedal(
      frontPhotoUrl: try makeStoredPhoto(.red), backPhotoUrl: try makeStoredPhoto(.blue))
    let viewModel = makeViewModel(medal: medal)

    await viewModel.loadStoredPhotos()

    #expect(viewModel.photoContent(for: .front).shownPhoto != nil)
    #expect(viewModel.photoContent(for: .back).shownPhoto != nil)
  }

  @Test("a face cropped while the stored faces load is kept")
  func testCroppedFaceSurvivesLoad() async throws {
    let medal = makeMedal(frontPhotoUrl: try makeStoredPhoto(.red))
    let viewModel = makeViewModel(medal: medal)
    viewModel.updatePhoto(with: try CroppedPhoto(checking: croppedPhoto), for: .front)

    await viewModel.loadStoredPhotos()

    #expect(viewModel.photoContent(for: .front).shownPhoto === croppedPhoto)
  }

  @Test("a cropped photo is staged for its own face only")
  func testCroppedPhotoStagedForItsFace() throws {
    let viewModel = makeViewModel()

    viewModel.updatePhoto(with: try CroppedPhoto(checking: croppedPhoto), for: .back)

    #expect(viewModel.photoContent(for: .back).shownPhoto === croppedPhoto)
    #expect(viewModel.photoContent(for: .front) == .empty)
  }

  @Test("a cropped photo replaces the face's stored photo")
  func testCroppedPhotoReplacesStoredFace() async throws {
    let medal = makeMedal(frontPhotoUrl: try makeStoredPhoto(.red))
    let viewModel = makeViewModel(medal: medal)
    await viewModel.loadStoredPhotos()
    let storedFront = try #require(viewModel.photoContent(for: .front).shownPhoto)

    viewModel.updatePhoto(with: try CroppedPhoto(checking: croppedPhoto), for: .front)

    #expect(viewModel.photoContent(for: .front).shownPhoto === croppedPhoto)
    #expect(viewModel.photoContent(for: .front).shownPhoto !== storedFront)
  }

  @Test("removing a face leaves the other face staged")
  func testRemovingAFaceKeepsTheOther() throws {
    let viewModel = makeViewModel()
    viewModel.updatePhoto(with: try TestPhotos.cropped(), for: .front)
    viewModel.updatePhoto(with: try CroppedPhoto(checking: croppedPhoto), for: .back)

    viewModel.removePhoto(for: .front)

    #expect(viewModel.photoContent(for: .front) == .empty)
    #expect(viewModel.photoContent(for: .back).shownPhoto === croppedPhoto)
  }

  // MARK: - Stored photo status
  @Test("a stored face is loading until it downloads")
  func testStoredFaceLoads() async throws {
    let viewModel = makeViewModel(medal: makeMedal(frontPhotoUrl: try makeStoredPhoto(.red)))
    #expect(viewModel.photoContent(for: .front) == .loading)

    await viewModel.loadStoredPhotos()

    #expect(viewModel.photoContent(for: .front).shownPhoto != nil)
  }

  @Test("a stored face that can't be downloaded is marked failed")
  func testStoredFaceFails() async {
    let viewModel = makeViewModel(
      medal: makeMedal(frontPhotoUrl: "file:///nonexistent/stored-photo.jpg"))

    await viewModel.loadStoredPhotos()

    #expect(viewModel.photoContent(for: .front) == .failed)
  }

  @Test("a face with no stored photo stays empty")
  func testFaceWithoutStoredPhoto() async throws {
    let viewModel = makeViewModel(medal: makeMedal(frontPhotoUrl: try makeStoredPhoto(.red)))
    #expect(viewModel.photoContent(for: .back) == .empty)

    await viewModel.loadStoredPhotos()

    #expect(viewModel.photoContent(for: .back) == .empty)
  }

  @Test("cropping or removing a face ends its stored photo's status", arguments: [true, false])
  func testChangingFaceEndsStatus(crops: Bool) async throws {
    let viewModel = makeViewModel(
      medal: makeMedal(frontPhotoUrl: "file:///nonexistent/stored-photo.jpg"))
    await viewModel.loadStoredPhotos()

    if crops {
      viewModel.updatePhoto(with: try CroppedPhoto(checking: croppedPhoto), for: .front)
    } else {
      viewModel.removePhoto(for: .front)
    }

    #expect(
      crops
        ? viewModel.photoContent(for: .front).shownPhoto === croppedPhoto
        : viewModel.photoContent(for: .front) == .empty)
  }
}
