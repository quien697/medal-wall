//
//  EditMedalViewModelSaveTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-10.
//

import Foundation
import Testing
import UIKit

@testable import MedalWall

@MainActor
struct EditMedalViewModelSaveTests {

  // MARK: - Helpers
  private let raceDay = Date(timeIntervalSince1970: 1_734_739_200)
  private let division = Division(gender: .male, ageGroup: .from30to34)

  /// A saved medal whose values all differ from what `fillForm` enters, and which also holds
  /// fields the form doesn't show: a cover photo, a creation date, and captioned event photos.
  private func makeMedal() -> Medal {
    var medal = Medal(
      id: "medal-taipei",
      name: "Taipei Marathon",
      date: Date(timeIntervalSince1970: 1_577_836_800),
      bibNumber: "00001",
      photoUrl: "https://example.com/cover.jpg",
      place: Place(countryCode: "TW", city: "Taipei City"),
      distance: .default,
      note: "Old note",
      userID: "uid",
      createdAt: Date(timeIntervalSince1970: 1_577_923_200)
    )
    medal.eventPhotos = [
      EventPhoto(
        id: "event-start", imageUrl: "https://example.com/start.jpg", caption: "Start line",
        sortOrder: 0, createdAt: Date(timeIntervalSince1970: 1_578_009_600)),
      EventPhoto(
        id: "event-finish", imageUrl: "https://example.com/finish.jpg", caption: "Finish line",
        sortOrder: 1, createdAt: Date(timeIntervalSince1970: 1_578_096_000))
    ]
    return medal
  }

  /// A view model saving through `repository`, with stub storage and a connected network.
  private func makeViewModel(
    mode: ItemEditMode, medal: Medal? = nil, repository: StubMedalRepository
  ) -> EditMedalViewModel {
    EditMedalViewModel(
      mode: mode, medal: medal, repository: repository, storageService: StubPhotoStorage(),
      networkMonitor: StubNetworkMonitor())
  }

  /// Fills every form field with a value no other field shares, so a field saved into the
  /// wrong slot shows up.
  private func fillForm(_ viewModel: EditMedalViewModel) {
    viewModel.name = "Tokyo Marathon"
    viewModel.date = raceDay
    viewModel.bibNumber = "F1234"
    viewModel.place = Place(countryCode: "JP", city: "Tokyo")
    viewModel.distance = RaceDistance(category: .half, type: .virtual)
    viewModel.finishTime = 12_345
    viewModel.overallPlacement = 120
    viewModel.totalParticipants = 3_000
    viewModel.division = division
    viewModel.divisionPlacement = 15
    viewModel.divisionTotal = 400
    viewModel.genderPlacement = 90
    viewModel.genderTotal = 1_500
    viewModel.note = "Rainy start"
    viewModel.tags = ["pb", "rain"]
  }

  /// The medal `save` wrote: the created one when adding, the updated one when editing.
  private func savedMedal(_ mode: ItemEditMode, in repository: StubMedalRepository) async
    -> Medal?
  {
    mode == .add ? await repository.createdMedals.first : await repository.updatedMedals.first
  }

  /// Checks that a saved medal holds exactly what `fillForm` entered.
  private func expectFilledForm(_ medal: Medal) {
    #expect(medal.name == "Tokyo Marathon")
    #expect(medal.date == raceDay)
    #expect(medal.bibNumber == "F1234")
    #expect(medal.place == Place(countryCode: "JP", city: "Tokyo"))
    #expect(medal.distance == RaceDistance(category: .half, type: .virtual))
    #expect(medal.finishTime == 12_345)
    #expect(medal.overallPlacement == 120)
    #expect(medal.totalParticipants == 3_000)
    #expect(medal.division == division.rawValue)
    #expect(medal.divisionPlacement == 15)
    #expect(medal.divisionTotal == 400)
    #expect(medal.genderPlacement == 90)
    #expect(medal.genderTotal == 1_500)
    #expect(medal.note == "Rainy start")
    #expect(medal.tags == ["pb", "rain"])
  }

  // MARK: - Medal fields
  @Test("a new medal is created with every field from the form")
  func testCreateSavesEveryField() async throws {
    let repository = StubMedalRepository()
    let viewModel = makeViewModel(mode: .add, repository: repository)
    fillForm(viewModel)

    try await viewModel.save(by: "uid")

    let created = try #require(await repository.createdMedals.first)
    expectFilledForm(created)
    #expect(created.userID == "uid")
    #expect(created.photoUrl == nil)
    #expect(created.eventPhotos.isEmpty)
  }

  @Test("an edited medal takes every field from the form and keeps the ones it doesn't show")
  func testEditSavesEveryField() async throws {
    let medal = makeMedal()
    let repository = StubMedalRepository(medals: [medal])
    let viewModel = makeViewModel(mode: .edit, medal: medal, repository: repository)
    fillForm(viewModel)

    try await viewModel.save(by: "editor-uid")

    let updated = try #require(await repository.updatedMedals.first)
    expectFilledForm(updated)
    #expect(updated.id == "medal-taipei")
    #expect(updated.userID == "uid")
    #expect(updated.createdAt == Date(timeIntervalSince1970: 1_577_923_200))
    #expect(updated.photoUrl == "https://example.com/cover.jpg")
  }

  @Test(
    "name, bib number and note are saved without surrounding whitespace or line breaks",
    arguments: [ItemEditMode.add, .edit])
  func testTextFieldsSavedTrimmed(mode: ItemEditMode) async throws {
    let medal = makeMedal()
    let repository = StubMedalRepository(medals: [medal])
    let viewModel = makeViewModel(
      mode: mode, medal: mode == .edit ? medal : nil, repository: repository)
    viewModel.name = "  Tokyo Marathon\n"
    viewModel.bibNumber = "\n F1234  "
    viewModel.note = "\n Rainy start \n"

    try await viewModel.save(by: "uid")

    let saved = try #require(await savedMedal(mode, in: repository))
    #expect(saved.name == "Tokyo Marathon")
    #expect(saved.bibNumber == "F1234")
    #expect(saved.note == "Rainy start")
  }

  @Test(
    "an empty or whitespace-only note is saved as no note",
    arguments: [ItemEditMode.add, .edit], ["", "  \n "])
  func testBlankNoteSavedAsNil(mode: ItemEditMode, note: String) async throws {
    let medal = makeMedal()
    let repository = StubMedalRepository(medals: [medal])
    let viewModel = makeViewModel(
      mode: mode, medal: mode == .edit ? medal : nil, repository: repository)
    viewModel.note = note

    try await viewModel.save(by: "uid")

    let saved = try #require(await savedMedal(mode, in: repository))
    #expect(saved.note == nil)
  }

  // MARK: - Event photos
  /// A 1×1 PNG standing in for a photo the user picked.
  private func makePhotoData() throws -> Data {
    let image = UIGraphicsImageRenderer(size: CGSize(width: 1, height: 1)).image { context in
      UIColor.red.setFill()
      context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
    }
    return try #require(image.pngData())
  }

  @Test("a kept event photo keeps its caption and creation date")
  func testKeptEventPhotoKeepsStoredFields() async throws {
    let medal = makeMedal()
    let repository = StubMedalRepository(medals: [medal])
    let viewModel = makeViewModel(mode: .edit, medal: medal, repository: repository)
    viewModel.note = "New note"

    try await viewModel.save(by: "uid")

    let eventPhotos = try #require(await repository.updatedMedals.first?.eventPhotos)
    #expect(eventPhotos.map(\.caption) == ["Start line", "Finish line"])
    #expect(
      eventPhotos.map(\.createdAt) == [
        Date(timeIntervalSince1970: 1_578_009_600), Date(timeIntervalSince1970: 1_578_096_000)
      ])
  }

  @Test("a new event photo is saved with its draft id and upload URL, and order is renumbered")
  func testNewEventPhotoSavedInOrder() async throws {
    let medal = makeMedal()
    let repository = StubMedalRepository(medals: [medal])
    let viewModel = makeViewModel(mode: .edit, medal: medal, repository: repository)
    viewModel.removeEventPhoto(id: "event-start")
    viewModel.addEventPhotos([try makePhotoData()])
    let newPhotoID = try #require(viewModel.draftEventPhotos.last?.id)

    try await viewModel.save(by: "uid")

    let eventPhotos = try #require(await repository.updatedMedals.first?.eventPhotos)
    #expect(eventPhotos.map(\.id) == ["event-finish", newPhotoID])
    #expect(
      eventPhotos.map(\.imageUrl) == [
        "https://example.com/finish.jpg", "https://example.com/uploaded.jpg"
      ])
    #expect(eventPhotos.map(\.sortOrder) == [0, 1])
  }
}
