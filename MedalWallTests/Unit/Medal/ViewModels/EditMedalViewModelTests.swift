//
//  EditMedalViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-29.
//

import Foundation
import Testing
import UIKit

@testable import MedalWall

struct EditMedalViewModelTests {

  // MARK: - isFormValid
  @Test("isFormValid is false by default with no fields set")
  func testIsFormValidFalseByDefault() {
    let viewModel = EditMedalViewModel(mode: .add)

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is true when name, country, and city are set")
  func testIsFormValidTrueWithRequiredFields() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = "Taipei Marathon 2019"
    viewModel.place.countryCode = "TW"
    viewModel.place.city = "Taipei"

    #expect(viewModel.isFormValid == true)
  }

  @Test("isFormValid is false when name is empty")
  func testIsFormValidFalseEmptyName() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = ""
    viewModel.place.countryCode = "TW"
    viewModel.place.city = "Taipei"

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when name is only whitespace")
  func testIsFormValidFalseWhitespaceName() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = "   "
    viewModel.place.countryCode = "TW"
    viewModel.place.city = "Taipei"

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when name is only a pasted line break")
  func testIsFormValidFalseNewlineName() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = " \n"
    viewModel.place.countryCode = "TW"
    viewModel.place.city = "Taipei"

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when country is empty")
  func testIsFormValidFalseEmptyCountry() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = "Taipei Marathon 2019"
    viewModel.place.countryCode = ""
    viewModel.place.city = "Taipei"

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when city is empty")
  func testIsFormValidFalseEmptyCity() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = "Taipei Marathon 2019"
    viewModel.place.countryCode = "TW"
    viewModel.place.city = ""

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when country is only whitespace")
  func testIsFormValidFalseWhitespaceCountry() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = "Taipei Marathon 2019"
    viewModel.place.countryCode = "   "
    viewModel.place.city = "Taipei"

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when city is only whitespace")
  func testIsFormValidFalseWhitespaceCity() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = "Taipei Marathon 2019"
    viewModel.place.countryCode = "TW"
    viewModel.place.city = "   "

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when custom distance is zero")
  func testIsFormValidFalseCustomDistanceZero() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = "Taipei Marathon 2019"
    viewModel.place.countryCode = "TW"
    viewModel.place.city = "Taipei"
    viewModel.distance = RaceEvent(
      category: RaceDistanceCategory(value: 0, unit: .kilometers), type: .inPerson)

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when custom distance is negative")
  func testIsFormValidFalseCustomDistanceNegative() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = "Taipei Marathon 2019"
    viewModel.place.countryCode = "TW"
    viewModel.place.city = "Taipei"
    viewModel.distance = RaceEvent(
      category: RaceDistanceCategory(value: -1, unit: .kilometers), type: .inPerson)

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is true when custom distance is positive")
  func testIsFormValidTrueCustomDistancePositive() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = "Taipei Marathon 2019"
    viewModel.place.countryCode = "TW"
    viewModel.place.city = "Taipei"
    viewModel.distance = RaceEvent(
      category: RaceDistanceCategory(value: 5.0, unit: .kilometers), type: .inPerson)

    #expect(viewModel.isFormValid == true)
  }

  @Test(
    "isFormValid is false for more than four decimals, non-finite values, or 10,000 or more",
    arguments: [10.12345, Double.nan, .infinity, 10_000])
  func testIsFormValidFalseCustomDistanceUnusable(value: Double) {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = "Taipei Marathon 2019"
    viewModel.place.countryCode = "TW"
    viewModel.place.city = "Taipei"
    viewModel.distance = RaceEvent(
      category: RaceDistanceCategory(value: value, unit: .miles), type: .inPerson)

    #expect(viewModel.isFormValid == false)
  }

  // MARK: - selectDistance
  @Test(
    "selectDistance refuses an invalid custom distance and keeps the current one",
    arguments: [0, -1, 10.12345, Double.nan, .infinity, 10_000])
  func testSelectDistanceRefusesInvalidCustom(value: Double) {
    let viewModel = EditMedalViewModel(mode: .add)
    let current = viewModel.distance

    #expect(throws: AppError.invalidDistance) {
      try viewModel.selectDistance(
        RaceEvent(category: RaceDistanceCategory(value: value, unit: .miles), type: .inPerson))
    }
    #expect(viewModel.distance == current)
  }

  @Test("selectDistance sets a valid custom distance as entered")
  func testSelectDistanceAcceptsValidCustom() throws {
    let viewModel = EditMedalViewModel(mode: .add)
    let distance = RaceEvent(
      category: RaceDistanceCategory(value: 10.1234, unit: .miles), type: .virtual)

    try viewModel.selectDistance(distance)

    #expect(viewModel.distance == distance)
  }

  @Test("selectDistance sets a standard distance")
  func testSelectDistanceAcceptsStandard() throws {
    let viewModel = EditMedalViewModel(mode: .add)
    let distance = RaceEvent(category: .half, type: .wheelChair)

    try viewModel.selectDistance(distance)

    #expect(viewModel.distance == distance)
  }

  // MARK: - addEventPhotos / removeEventPhoto
  /// JPEG data of a small plain photo, well under the upload limit.
  private func makePhotoData() throws -> Data {
    try #require(TestPhotos.plain(width: 40, height: 30).jpegData(compressionQuality: 0.8))
  }

  @Test("addEventPhotos appends one DraftEventPhoto per photo")
  func testAddEventPhotosAppendsAll() async throws {
    let viewModel = EditMedalViewModel(mode: .add)

    try await viewModel.addEventPhotos([try makePhotoData(), try makePhotoData()])

    #expect(viewModel.draftEventPhotos.count == 2)
  }

  @Test("a large picked photo is staged as the picked bytes, unchanged")
  func testLargeEventPhotoIsStagedAsPicked() async throws {
    let viewModel = EditMedalViewModel(mode: .add)
    let pickedData = try #require(
      TestPhotos.plain(width: 4000, height: 3000).jpegData(compressionQuality: 0.8))

    try await viewModel.addEventPhotos([pickedData])

    #expect(viewModel.draftEventPhotos.first?.data == pickedData)
  }

  @Test("a photo over the upload limit is skipped, the others are added, and it is reported")
  func testEventPhotoOverLimitIsSkipped() async throws {
    let viewModel = EditMedalViewModel(mode: .add)
    let smallData = try makePhotoData()
    let largeData = try #require(TestPhotos.noise()?.jpegData(compressionQuality: 0.8))

    await #expect(throws: AppError.photoTooLarge) {
      try await viewModel.addEventPhotos([smallData, largeData, Data("not an image".utf8)])
    }

    #expect(viewModel.draftEventPhotos.map(\.data) == [smallData])
  }

  @Test("data that is not an image is skipped, the others are added, and it is reported")
  func testUnreadableEventPhotoIsSkipped() async throws {
    let viewModel = EditMedalViewModel(mode: .add)
    let smallData = try makePhotoData()

    await #expect(throws: AppError.photoDataInvalid) {
      try await viewModel.addEventPhotos([smallData, Data("not an image".utf8)])
    }

    #expect(viewModel.draftEventPhotos.map(\.data) == [smallData])
  }

  @Test("removeEventPhoto removes the matching photo by id")
  func testRemoveEventPhotoRemovesById() async throws {
    let viewModel = EditMedalViewModel(mode: .add)
    try await viewModel.addEventPhotos([try makePhotoData(), try makePhotoData()])
    let idToRemove = viewModel.draftEventPhotos[0].id

    viewModel.removeEventPhoto(id: idToRemove)

    #expect(viewModel.draftEventPhotos.count == 1)
    #expect(viewModel.draftEventPhotos.first?.id != idToRemove)
  }

  @Test("removeEventPhoto is a no-op when id is not found")
  func testRemoveEventPhotoNoOpWhenNotFound() async throws {
    let viewModel = EditMedalViewModel(mode: .add)
    try await viewModel.addEventPhotos([try makePhotoData()])

    viewModel.removeEventPhoto(id: "non-existent-id")

    #expect(viewModel.draftEventPhotos.count == 1)
  }

  // MARK: - autoFill
  @Test("autoFill copies the whole place, name, and distance from the selection")
  func testAutoFillPopulatesFields() {
    let viewModel = EditMedalViewModel(mode: .add)
    let race = Race.sampleData.first!
    let edition = RaceEdition.sampleData.first!
    let distance = RaceEvent(category: .full, type: .inPerson)
    let selection = RaceEntry(race: race, edition: edition, raceEvent: distance)

    viewModel.autoFill(from: selection)

    #expect(viewModel.name == "\(race.name) \(edition.year)")
    #expect(viewModel.place == race.place)
    #expect(viewModel.distance == distance)
  }

  // MARK: - Edit mode init
  @Test("init in edit mode loads fields from the medal")
  func testInitEditModeLoadsFields() {
    let someDate = Date(timeIntervalSinceReferenceDate: 0)
    let medal = Medal(
      name: "Test Race 2025",
      date: someDate,
      bibNumber: "42",
      place: Place(countryCode: "JP", city: "Shinjuku", region: "Tokyo"),
      raceEvent: RaceEvent(category: .full, type: .inPerson),
      result: .seconds(12624),
      note: "Great race",
      tags: ["fun"],
      userID: "user1"
    )
    let viewModel = EditMedalViewModel(mode: .edit, medal: medal)

    #expect(viewModel.name == "Test Race 2025")
    #expect(viewModel.place.countryCode == "JP")
    #expect(viewModel.place.region == "Tokyo")
    #expect(viewModel.place.city == "Shinjuku")
    #expect(viewModel.finishTime == 12624)
    #expect(viewModel.note == "Great race")
    #expect(viewModel.tags == ["fun"])
  }

  /// The finish time picker traps on infinity or a value near 1e20, so a stored time the app
  /// already reads as unrecorded must open the editor empty instead of crashing it.
  @Test(
    "init in edit mode leaves an unusable stored finish time empty",
    arguments: [TimeInterval.infinity, 1e20, 0, -1])
  func testInitEditModeDropsUnusableFinishTime(finishTime: TimeInterval) {
    let medal = Medal(
      name: "Test Race 2025",
      date: .now,
      bibNumber: "42",
      place: Place(countryCode: "JP", city: "Shinjuku"),
      raceEvent: RaceEvent(category: .full, type: .inPerson),
      result: .seconds(finishTime),
      userID: "user1"
    )
    let viewModel = EditMedalViewModel(mode: .edit, medal: medal)

    #expect(viewModel.finishTime == nil)
  }

  // MARK: - Tags
  @Test("addTag trims the whitespace and line breaks around a tag")
  func testAddTagTrims() {
    let viewModel = EditMedalViewModel(mode: .add)

    viewModel.addTag("  taipei \n")

    #expect(viewModel.tags == ["taipei"])
  }

  @Test("addTag ignores a tag that is already there")
  func testAddTagIgnoresDuplicate() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.tags = ["taipei"]

    viewModel.addTag("taipei")

    #expect(viewModel.tags == ["taipei"])
  }

  @Test("addTag ignores a blank tag")
  func testAddTagIgnoresBlank() {
    let viewModel = EditMedalViewModel(mode: .add)

    viewModel.addTag(" \n ")

    #expect(viewModel.tags.isEmpty)
  }

  @Test("removeTag removes only that tag")
  func testRemoveTag() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.tags = ["marathon", "taipei"]

    viewModel.removeTag("marathon")

    #expect(viewModel.tags == ["taipei"])
  }
}
