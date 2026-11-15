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
/// framed photos.
@MainActor
struct EditMedalViewModelPhotoTests {

  private let framedPhoto = UIImage()

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

    await viewModel.loadPhotos()

    #expect(viewModel.photo(for: .front) != nil)
    #expect(viewModel.photo(for: .back) != nil)
  }

  @Test("a face framed while the stored faces load is kept")
  func testFramedFaceSurvivesLoad() async throws {
    let medal = makeMedal(frontPhotoUrl: try makeStoredPhoto(.red))
    let viewModel = makeViewModel(medal: medal)
    viewModel.updatePhoto(with: framedPhoto, for: .front)

    await viewModel.loadPhotos()

    #expect(viewModel.photo(for: .front) === framedPhoto)
  }

  @Test("a framed photo is staged for its own face only")
  func testFramedPhotoStagedForItsFace() {
    let viewModel = makeViewModel()

    viewModel.updatePhoto(with: framedPhoto, for: .back)

    #expect(viewModel.photo(for: .back) === framedPhoto)
    #expect(viewModel.photo(for: .front) == nil)
  }

  @Test("a framed photo replaces the face's stored photo")
  func testFramedPhotoReplacesStoredFace() async throws {
    let medal = makeMedal(frontPhotoUrl: try makeStoredPhoto(.red))
    let viewModel = makeViewModel(medal: medal)
    await viewModel.loadPhotos()
    let storedFront = try #require(viewModel.photo(for: .front))

    viewModel.updatePhoto(with: framedPhoto, for: .front)

    #expect(viewModel.photo(for: .front) === framedPhoto)
    #expect(viewModel.photo(for: .front) !== storedFront)
  }

  @Test("removing a face leaves the other face staged")
  func testRemovingAFaceKeepsTheOther() {
    let viewModel = makeViewModel()
    viewModel.updatePhoto(with: UIImage(), for: .front)
    viewModel.updatePhoto(with: framedPhoto, for: .back)

    viewModel.clearPhoto(for: .front)

    #expect(viewModel.photo(for: .front) == nil)
    #expect(viewModel.photo(for: .back) === framedPhoto)
  }

  // MARK: - Stored photo status
  @Test("a stored face is loading until it downloads")
  func testStoredFaceLoads() async throws {
    let viewModel = makeViewModel(medal: makeMedal(frontPhotoUrl: try makeStoredPhoto(.red)))
    #expect(viewModel.storedPhotoStatus(for: .front) == .loading)

    await viewModel.loadPhotos()

    #expect(viewModel.storedPhotoStatus(for: .front) == nil)
  }

  @Test("a stored face that can't be downloaded is marked failed")
  func testStoredFaceFails() async {
    let viewModel = makeViewModel(
      medal: makeMedal(frontPhotoUrl: "file:///nonexistent/stored-photo.jpg"))

    await viewModel.loadPhotos()

    #expect(viewModel.storedPhotoStatus(for: .front) == .failed)
    #expect(viewModel.photo(for: .front) == nil)
  }

  @Test("a face with no stored photo has no status")
  func testFaceWithoutStoredPhoto() async throws {
    let viewModel = makeViewModel(medal: makeMedal(frontPhotoUrl: try makeStoredPhoto(.red)))
    #expect(viewModel.storedPhotoStatus(for: .back) == nil)

    await viewModel.loadPhotos()

    #expect(viewModel.storedPhotoStatus(for: .back) == nil)
  }

  @Test("framing or removing a face ends its stored photo's status", arguments: [true, false])
  func testChangingFaceEndsStatus(frames: Bool) async {
    let viewModel = makeViewModel(
      medal: makeMedal(frontPhotoUrl: "file:///nonexistent/stored-photo.jpg"))
    await viewModel.loadPhotos()

    if frames {
      viewModel.updatePhoto(with: framedPhoto, for: .front)
    } else {
      viewModel.clearPhoto(for: .front)
    }

    #expect(viewModel.storedPhotoStatus(for: .front) == nil)
  }
}
