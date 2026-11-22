//
//  EditMedalViewModelEventPhotoTests.swift
//  MedalWall
//
//  Created by Quien on 2026-11-22.
//

import Foundation
import PhotosUI
import SwiftUI
import Testing
import UIKit

@testable import MedalWall

/// Covers loading the event photos picked in the photo library, and Save waiting while they are
/// loaded and checked.
struct EditMedalViewModelEventPhotoTests {

  // MARK: - Helpers
  /// What a loader saw while it ran: whether Save could be tapped and the photos were checking.
  /// It holds the view model weakly: the view model holds the loader, which holds the recorder.
  private final class LoadRecorder {
    weak var viewModel: EditMedalViewModel?
    var canSaveWhileLoading: Bool?
    var isCheckingWhileLoading: Bool?
  }

  /// A form with a name, country and city, which Save accepts, loading each picked item as the
  /// data `dataByItem` holds for its identifier, or as nothing.
  private func makeValidViewModel(
    dataByItem: [String: Data],
    recorder: LoadRecorder = LoadRecorder()
  ) -> EditMedalViewModel {
    let viewModel = EditMedalViewModel(
      mode: .add,
      loadPickedPhoto: { item in
        recorder.canSaveWhileLoading = recorder.viewModel?.canSave
        recorder.isCheckingWhileLoading = recorder.viewModel?.isCheckingEventPhotos
        return item.itemIdentifier.flatMap { dataByItem[$0] }
      }
    )
    viewModel.name = "Taipei Marathon 2019"
    viewModel.place.countryCode = "TW"
    viewModel.place.city = "Taipei"
    recorder.viewModel = viewModel
    return viewModel
  }

  private func makePhotoData() throws -> Data {
    try #require(TestPhotos.plain(width: 40, height: 30).jpegData(compressionQuality: 0.8))
  }

  private func items(_ identifiers: String...) -> [PhotosPickerItem] {
    identifiers.map { PhotosPickerItem(itemIdentifier: $0) }
  }

  // MARK: - Loading
  @Test("each picked event photo is loaded and staged")
  func testPickedPhotosAreStaged() async throws {
    let viewModel = makeValidViewModel(
      dataByItem: ["a": try makePhotoData(), "b": try makePhotoData()])

    try await viewModel.addEventPhotos(from: items("a", "b"))

    #expect(viewModel.draftEventPhotos.count == 2)
  }

  @Test("a picked item that can't be loaded is skipped, and reported as not an image")
  func testUnloadableItemIsSkipped() async throws {
    let viewModel = makeValidViewModel(dataByItem: ["a": try makePhotoData()])

    await #expect(throws: AppError.photoDataInvalid) {
      try await viewModel.addEventPhotos(from: items("a", "missing"))
    }

    #expect(viewModel.draftEventPhotos.count == 1)
  }

  @Test("a photo too large is reported over an item that can't be loaded")
  func testTooLargeIsReportedOverUnloadable() async throws {
    let largeData = try #require(TestPhotos.noise()?.jpegData(compressionQuality: 0.8))
    let viewModel = makeValidViewModel(dataByItem: ["a": try makePhotoData(), "large": largeData])

    await #expect(throws: AppError.photoTooLarge) {
      try await viewModel.addEventPhotos(from: items("a", "large", "missing"))
    }

    #expect(viewModel.draftEventPhotos.count == 1)
  }

  // MARK: - Save while checking
  @Test("Save waits while picked event photos are loaded and checked, and not after")
  func testSaveWaitsWhileEventPhotosAreChecked() async throws {
    let recorder = LoadRecorder()
    let viewModel = makeValidViewModel(dataByItem: ["a": try makePhotoData()], recorder: recorder)
    #expect(viewModel.canSave)

    try await viewModel.addEventPhotos(from: items("a"))

    #expect(recorder.isCheckingWhileLoading == true)
    #expect(recorder.canSaveWhileLoading == false)
    #expect(!viewModel.isCheckingEventPhotos)
    #expect(viewModel.canSave)
  }
}
