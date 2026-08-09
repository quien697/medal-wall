//
//  EditRaceViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-28.
//

import Foundation
import Testing

@testable import MedalWall

struct EditRaceViewModelTests {
  private let place = Place(countryCode: "CA", city: "Vancouver")

  private func makeDraft(startDate: Date = Date(timeIntervalSinceReferenceDate: 0))
    -> DraftRaceEdition
  {
    DraftRaceEdition(
      year: 2025, isOneDay: true,
      startDate: startDate, endDate: startDate,
      distances: [], createdBy: "user-1"
    )
  }

  // MARK: - isFormValid
  @Test("isFormValid is false when name is empty")
  func testIsFormValidEmptyName() {
    let viewModel = EditRaceViewModel(mode: .add, race: nil)
    viewModel.place.countryCode = "CA"
    viewModel.place.city = "Vancouver"

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when country is empty")
  func testIsFormValidEmptyCountry() {
    let viewModel = EditRaceViewModel(mode: .add, race: nil)
    viewModel.name = "Boston Marathon"
    viewModel.place.city = "Vancouver"

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when city is empty")
  func testIsFormValidEmptyCity() {
    let viewModel = EditRaceViewModel(mode: .add, race: nil)
    viewModel.name = "Boston Marathon"
    viewModel.place.countryCode = "CA"

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is true when name, country, and city are all filled")
  func testIsFormValidAllFilled() {
    let viewModel = EditRaceViewModel(mode: .add, race: nil)
    viewModel.name = "Boston Marathon"
    viewModel.place.countryCode = "CA"
    viewModel.place.city = "Vancouver"

    #expect(viewModel.isFormValid == true)
  }

  @Test("isFormValid is false when name is only whitespace")
  func testIsFormValidWhitespaceName() {
    let viewModel = EditRaceViewModel(mode: .add, race: nil)
    viewModel.name = "   "
    viewModel.place.countryCode = "CA"
    viewModel.place.city = "Vancouver"

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when country is only whitespace")
  func testIsFormValidWhitespaceCountry() {
    let viewModel = EditRaceViewModel(mode: .add, race: nil)
    viewModel.name = "Boston Marathon"
    viewModel.place.countryCode = "   "
    viewModel.place.city = "Vancouver"

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when city is only whitespace")
  func testIsFormValidWhitespaceCity() {
    let viewModel = EditRaceViewModel(mode: .add, race: nil)
    viewModel.name = "Boston Marathon"
    viewModel.place.countryCode = "CA"
    viewModel.place.city = "   "

    #expect(viewModel.isFormValid == false)
  }

  // MARK: - Edit mode pre-population
  @Test("init in edit mode pre-populates fields from the race")
  func testEditModePrePopulates() {
    let race = Race(
      name: "Boston Marathon",
      place: Place(countryCode: "US", city: "Boston", region: "MA"),
      websiteUrl: "baa.org",
      createdBy: "user-1"
    )
    let viewModel = EditRaceViewModel(mode: .edit, race: race)

    #expect(viewModel.name == "Boston Marathon")
    #expect(viewModel.place.countryCode == "US")
    #expect(viewModel.place.region == "MA")
    #expect(viewModel.place.city == "Boston")
    #expect(viewModel.websiteUrl == "baa.org")
  }

  @Test("init in add mode starts with empty fields")
  func testAddModeStartsEmpty() {
    let viewModel = EditRaceViewModel(mode: .add, race: nil)

    #expect(viewModel.name.isEmpty)
    #expect(viewModel.place.countryCode.isEmpty)
    #expect(viewModel.place.city.isEmpty)
  }

  @Test("init in edit mode leaves an absent region absent, with empty editable text")
  func testEditModeAbsentRegion() {
    let race = Race(
      name: "Test Race",
      place: Place(countryCode: "CA", city: "Vancouver"),
      createdBy: "user-1"
    )
    let viewModel = EditRaceViewModel(mode: .edit, race: race)

    #expect(viewModel.place.region == nil)
  }

  @Test("init in edit mode maps nil websiteUrl to empty string")
  func testEditModeNilWebsiteUrlFallsToEmpty() {
    let race = Race(name: "Test Race", place: place, createdBy: "user-1")
    let viewModel = EditRaceViewModel(mode: .edit, race: race)

    #expect(viewModel.websiteUrl.isEmpty)
  }

  // MARK: - Edition staging
  @Test("stageAddEdition appends a draft to displayedEditions")
  func testStageAddEdition() {
    let viewModel = EditRaceViewModel(mode: .add, race: nil)

    viewModel.stageAddEdition(makeDraft())

    #expect(viewModel.displayedEditions.count == 1)
  }

  @Test("stageUpdateEdition replaces the matching draft in displayedEditions")
  func testStageUpdateEdition() {
    let viewModel = EditRaceViewModel(mode: .add, race: nil)
    var draft = makeDraft()
    viewModel.stageAddEdition(draft)

    draft.year = 2026
    viewModel.stageUpdateEdition(draft)

    #expect(viewModel.displayedEditions.first?.year == 2026)
  }

  @Test("stageDeleteEdition removes an unsaved edition immediately")
  func testStageDeleteNewEdition() {
    let viewModel = EditRaceViewModel(mode: .add, race: nil)
    let draft = makeDraft()
    viewModel.stageAddEdition(draft)

    viewModel.stageDeleteEdition(id: draft.id)

    #expect(viewModel.displayedEditions.isEmpty)
  }

  @Test("stageUpdateEdition is a no-op when the id does not match any staged edition")
  func testStageUpdateEditionUnknownId() {
    let viewModel = EditRaceViewModel(mode: .add, race: nil)
    viewModel.stageAddEdition(makeDraft())

    let unknown = makeDraft()
    viewModel.stageUpdateEdition(unknown)

    #expect(viewModel.displayedEditions.count == 1)
  }

  @Test("stageAddEdition with multiple drafts results in correct count")
  func testStageAddMultipleEditions() {
    let viewModel = EditRaceViewModel(mode: .add, race: nil)

    viewModel.stageAddEdition(makeDraft())
    viewModel.stageAddEdition(makeDraft())
    viewModel.stageAddEdition(makeDraft())

    #expect(viewModel.displayedEditions.count == 3)
  }

  // MARK: - displayedEditions ordering
  @Test("displayedEditions are sorted by startDate descending")
  func testDisplayedEditionsSortedDescending() {
    let viewModel = EditRaceViewModel(mode: .add, race: nil)
    let older = makeDraft(startDate: Date(timeIntervalSinceReferenceDate: 0))
    let newer = makeDraft(startDate: Date(timeIntervalSinceReferenceDate: 86400 * 365))

    viewModel.stageAddEdition(older)
    viewModel.stageAddEdition(newer)

    #expect(viewModel.displayedEditions.first?.startDate == newer.startDate)
    #expect(viewModel.displayedEditions.last?.startDate == older.startDate)
  }

  @Test("displayedEditions order is correct for three editions with different start dates")
  func testDisplayedEditionsThreeEditionsSorted() {
    let viewModel = EditRaceViewModel(mode: .add, race: nil)
    let d1 = makeDraft(startDate: Date(timeIntervalSinceReferenceDate: 0))
    let d2 = makeDraft(startDate: Date(timeIntervalSinceReferenceDate: 86400 * 365))
    let d3 = makeDraft(startDate: Date(timeIntervalSinceReferenceDate: 86400 * 365 * 2))

    viewModel.stageAddEdition(d2)
    viewModel.stageAddEdition(d1)
    viewModel.stageAddEdition(d3)

    #expect(viewModel.displayedEditions[0].startDate == d3.startDate)
    #expect(viewModel.displayedEditions[1].startDate == d2.startDate)
    #expect(viewModel.displayedEditions[2].startDate == d1.startDate)
  }
}
