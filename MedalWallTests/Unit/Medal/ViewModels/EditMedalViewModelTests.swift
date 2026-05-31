//
//  EditMedalViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-29.
//

import Foundation
import Testing

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
    viewModel.country = "Taiwan"
    viewModel.city = "Taipei"

    #expect(viewModel.isFormValid == true)
  }

  @Test("isFormValid is false when name is empty")
  func testIsFormValidFalseEmptyName() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = ""
    viewModel.country = "Taiwan"
    viewModel.city = "Taipei"

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when name is only whitespace")
  func testIsFormValidFalseWhitespaceName() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = "   "
    viewModel.country = "Taiwan"
    viewModel.city = "Taipei"

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when country is empty")
  func testIsFormValidFalseEmptyCountry() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = "Taipei Marathon 2019"
    viewModel.country = ""
    viewModel.city = "Taipei"

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when city is empty")
  func testIsFormValidFalseEmptyCity() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = "Taipei Marathon 2019"
    viewModel.country = "Taiwan"
    viewModel.city = ""

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when country is only whitespace")
  func testIsFormValidFalseWhitespaceCountry() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = "Taipei Marathon 2019"
    viewModel.country = "   "
    viewModel.city = "Taipei"

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when city is only whitespace")
  func testIsFormValidFalseWhitespaceCity() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = "Taipei Marathon 2019"
    viewModel.country = "Taiwan"
    viewModel.city = "   "

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when custom distance is zero")
  func testIsFormValidFalseCustomDistanceZero() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = "Taipei Marathon 2019"
    viewModel.country = "Taiwan"
    viewModel.city = "Taipei"
    viewModel.distance = RaceDistance(category: .custom(0), type: .inPerson)

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when custom distance is negative")
  func testIsFormValidFalseCustomDistanceNegative() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = "Taipei Marathon 2019"
    viewModel.country = "Taiwan"
    viewModel.city = "Taipei"
    viewModel.distance = RaceDistance(category: .custom(-1), type: .inPerson)

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is true when custom distance is positive")
  func testIsFormValidTrueCustomDistancePositive() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.name = "Taipei Marathon 2019"
    viewModel.country = "Taiwan"
    viewModel.city = "Taipei"
    viewModel.distance = RaceDistance(category: .custom(5.0), type: .inPerson)

    #expect(viewModel.isFormValid == true)
  }

  // MARK: - addEventPhotos / removeEventPhoto
  @Test("addEventPhotos appends one DraftEventPhoto per data item")
  func testAddEventPhotosAppendsAll() {
    let viewModel = EditMedalViewModel(mode: .add)
    let data1 = Data([0x01])
    let data2 = Data([0x02])

    viewModel.addEventPhotos([data1, data2])

    #expect(viewModel.draftEventPhotos.count == 2)
  }

  @Test("removeEventPhoto removes the matching photo by id")
  func testRemoveEventPhotoRemovesById() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.addEventPhotos([Data([0x01]), Data([0x02])])
    let idToRemove = viewModel.draftEventPhotos[0].id

    viewModel.removeEventPhoto(id: idToRemove)

    #expect(viewModel.draftEventPhotos.count == 1)
    #expect(viewModel.draftEventPhotos.first?.id != idToRemove)
  }

  @Test("removeEventPhoto is a no-op when id is not found")
  func testRemoveEventPhotoNoOpWhenNotFound() {
    let viewModel = EditMedalViewModel(mode: .add)
    viewModel.addEventPhotos([Data([0x01])])

    viewModel.removeEventPhoto(id: "non-existent-id")

    #expect(viewModel.draftEventPhotos.count == 1)
  }

  // MARK: - autoFill
  @Test("autoFill populates name, country, city, and distance from the selection")
  func testAutoFillPopulatesFields() {
    let viewModel = EditMedalViewModel(mode: .add)
    let race = Race.sampleData.first!
    let edition = RaceEdition.sampleData.first!
    let distance = RaceDistance(category: .full, type: .inPerson)
    let selection = RaceEntry(race: race, edition: edition, distance: distance)

    viewModel.autoFill(from: selection)

    #expect(viewModel.name == "\(race.name) \(edition.year)")
    #expect(viewModel.country == race.location.country)
    #expect(viewModel.city == race.location.city)
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
      location: GeoLocation(country: "Japan", province: "Tokyo", city: "Shinjuku"),
      distance: RaceDistance(category: .full, type: .inPerson),
      finishTime: 12624,
      note: "Great race",
      tags: ["fun"],
      userID: "user1"
    )
    let viewModel = EditMedalViewModel(mode: .edit, medal: medal)

    #expect(viewModel.name == "Test Race 2025")
    #expect(viewModel.country == "Japan")
    #expect(viewModel.province == "Tokyo")
    #expect(viewModel.city == "Shinjuku")
    #expect(viewModel.finishTime == 12624)
    #expect(viewModel.note == "Great race")
    #expect(viewModel.tags == ["fun"])
  }
}
