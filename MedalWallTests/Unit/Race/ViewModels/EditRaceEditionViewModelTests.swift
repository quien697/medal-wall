//
//  EditRaceEditionViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-28.
//

import Testing
import UIKit

@testable import MedalWall

struct EditRaceEditionViewModelTests {

  private func makeViewModel() -> EditRaceEditionViewModel {
    EditRaceEditionViewModel(mode: .add, raceId: "test-race", edition: nil)
  }

  // MARK: - isFormValid
  @Test("isFormValid is true when year is in range and dates are equal")
  func testIsFormValidDefault() {
    let viewModel = makeViewModel()

    #expect(viewModel.isFormValid == true)
  }

  @Test("isFormValid is false when year is below the minimum")
  func testIsFormValidYearTooLow() {
    let viewModel = makeViewModel()
    viewModel.year = viewModel.minYear - 1

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when year is above the maximum")
  func testIsFormValidYearTooHigh() {
    let viewModel = makeViewModel()
    viewModel.year = viewModel.maxYear + 1

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is false when startDate is after endDate")
  func testIsFormValidStartAfterEnd() {
    let viewModel = makeViewModel()
    viewModel.startDate = Date(timeIntervalSinceReferenceDate: 86400)
    viewModel.endDate = Date(timeIntervalSinceReferenceDate: 0)

    #expect(viewModel.isFormValid == false)
  }

  @Test("isFormValid is true at the exact minimum year")
  func testIsFormValidAtMinYear() {
    let viewModel = makeViewModel()
    viewModel.year = viewModel.minYear

    #expect(viewModel.isFormValid == true)
  }

  @Test("isFormValid is true at the exact maximum year")
  func testIsFormValidAtMaxYear() {
    let viewModel = makeViewModel()
    viewModel.year = viewModel.maxYear

    #expect(viewModel.isFormValid == true)
  }

  @Test("isFormValid is true when startDate equals endDate")
  func testIsFormValidEqualDates() {
    let viewModel = makeViewModel()
    let day = Date(timeIntervalSinceReferenceDate: 0)
    viewModel.startDate = day
    viewModel.endDate = day

    #expect(viewModel.isFormValid == true)
  }

  // MARK: - toggleOneDay
  @Test("toggleOneDay aligns endDate to startDate when turned on")
  func testToggleOneDayAlignsDates() {
    let viewModel = makeViewModel()
    let start = Date(timeIntervalSinceReferenceDate: 0)
    let end = Date(timeIntervalSinceReferenceDate: 86400)
    viewModel.isOneDay = false
    viewModel.startDate = start
    viewModel.endDate = end

    viewModel.toggleOneDay()

    #expect(viewModel.isOneDay == true)
    #expect(viewModel.endDate == start)
  }

  @Test("toggleOneDay only flips the flag when turned off")
  func testToggleOneDayFlipsFlag() {
    let viewModel = makeViewModel()
    let end = Date(timeIntervalSinceReferenceDate: 86400)
    viewModel.isOneDay = true
    viewModel.endDate = end

    viewModel.toggleOneDay()

    #expect(viewModel.isOneDay == false)
    #expect(viewModel.endDate == end)
  }

  // MARK: - updateStartDate
  @Test("updateStartDate also moves endDate when isOneDay is true")
  func testUpdateStartDateOneDaySyncsEnd() {
    let viewModel = makeViewModel()
    viewModel.isOneDay = true
    let newStart = Date(timeIntervalSinceReferenceDate: 86400)

    viewModel.updateStartDate(newStart)

    #expect(viewModel.startDate == newStart)
    #expect(viewModel.endDate == newStart)
  }

  @Test("updateStartDate advances endDate when new start is after current end")
  func testUpdateStartDateAdvancesEnd() {
    let viewModel = makeViewModel()
    viewModel.isOneDay = false
    viewModel.endDate = Date(timeIntervalSinceReferenceDate: 0)
    let newStart = Date(timeIntervalSinceReferenceDate: 86400)

    viewModel.updateStartDate(newStart)

    #expect(viewModel.endDate == newStart)
  }

  @Test("updateStartDate preserves endDate when new start is before current end")
  func testUpdateStartDatePreservesEnd() {
    let viewModel = makeViewModel()
    viewModel.isOneDay = false
    let originalEnd = Date(timeIntervalSinceReferenceDate: 86400 * 5)
    viewModel.endDate = originalEnd
    let newStart = Date(timeIntervalSinceReferenceDate: 86400)

    viewModel.updateStartDate(newStart)

    #expect(viewModel.endDate == originalEnd)
  }

  @Test("updateStartDate preserves endDate when new start equals current end")
  func testUpdateStartDateEqualToEnd() {
    let viewModel = makeViewModel()
    viewModel.isOneDay = false
    let day = Date(timeIntervalSinceReferenceDate: 86400)
    viewModel.endDate = day

    viewModel.updateStartDate(day)

    #expect(viewModel.endDate == day)
  }

  // MARK: - removeDistance
  @Test("removeDistance removes the matching distance")
  func testRemoveDistance() throws {
    let viewModel = makeViewModel()
    let full = RaceDistance(category: .full, type: .inPerson)
    let half = RaceDistance(category: .half, type: .inPerson)
    try viewModel.addDistance(full)
    try viewModel.addDistance(half)

    viewModel.removeDistance(full)

    #expect(viewModel.distances.count == 1)
    #expect(viewModel.distances.first == half)
  }

  @Test("removeDistance on a distance not in the list has no effect")
  func testRemoveDistanceNotPresent() throws {
    let viewModel = makeViewModel()
    try viewModel.addDistance(RaceDistance(category: .full, type: .inPerson))

    viewModel.removeDistance(RaceDistance(category: .half, type: .inPerson))

    #expect(viewModel.distances.count == 1)
  }

  @Test("removeDistance on an empty list does not crash")
  func testRemoveDistanceFromEmptyList() {
    let viewModel = makeViewModel()

    viewModel.removeDistance(RaceDistance(category: .full, type: .inPerson))

    #expect(viewModel.distances.isEmpty)
  }

  // MARK: - photoHint
  @Test("photoHint prompts to add when photo is nil")
  func testPhotoHintNilPhoto() {
    let viewModel = makeViewModel()

    #expect(viewModel.photoHint.contains("add a new"))
  }

  @Test("photoHint prompts to update when photo is set")
  func testPhotoHintWithPhoto() {
    let viewModel = makeViewModel()
    viewModel.photo = UIImage()

    #expect(viewModel.photoHint.contains("update the"))
  }

  // MARK: - addDistance validation
  @Test("addDistance throws invalidDistance for a custom distance of zero")
  func testAddDistanceZeroThrows() {
    let viewModel = makeViewModel()

    #expect(throws: AppError.invalidDistance) {
      try viewModel.addDistance(RaceDistance(category: .custom(0), type: .inPerson))
    }
  }

  @Test("addDistance throws invalidDistance for a negative custom distance")
  func testAddDistanceNegativeThrows() {
    let viewModel = makeViewModel()

    #expect(throws: AppError.invalidDistance) {
      try viewModel.addDistance(RaceDistance(category: .custom(-5), type: .inPerson))
    }
  }

  @Test("addDistance throws duplicateDistance when the same distance is added twice")
  func testAddDistanceDuplicateThrows() throws {
    let viewModel = makeViewModel()
    let distance = RaceDistance(category: .full, type: .inPerson)
    try viewModel.addDistance(distance)

    #expect(throws: AppError.duplicateDistance) {
      try viewModel.addDistance(distance)
    }
  }

  @Test("addDistance succeeds for a valid standard distance")
  func testAddDistanceStandardSucceeds() throws {
    let viewModel = makeViewModel()
    try viewModel.addDistance(RaceDistance(category: .full, type: .inPerson))

    #expect(viewModel.distances.count == 1)
  }

  @Test("addDistance succeeds for a valid custom distance greater than zero")
  func testAddDistancePositiveCustomSucceeds() throws {
    let viewModel = makeViewModel()
    try viewModel.addDistance(RaceDistance(category: .custom(8.5), type: .inPerson))

    #expect(viewModel.distances.count == 1)
    #expect(viewModel.distances.first?.category == .custom(8.5))
  }

  @Test("addDistance does not add the distance when it throws")
  func testAddDistanceDoesNotMutateOnThrow() {
    let viewModel = makeViewModel()

    try? viewModel.addDistance(RaceDistance(category: .custom(0), type: .inPerson))

    #expect(viewModel.distances.isEmpty)
  }

  @Test("addDistance allows same category with different type — not a duplicate")
  func testAddDistanceSameCategoryDifferentTypeSucceeds() throws {
    let viewModel = makeViewModel()
    try viewModel.addDistance(RaceDistance(category: .full, type: .inPerson))
    try viewModel.addDistance(RaceDistance(category: .full, type: .virtual))

    #expect(viewModel.distances.count == 2)
  }

  @Test("addDistance succeeds for a very small positive custom distance")
  func testAddDistanceTinyPositiveCustomSucceeds() throws {
    let viewModel = makeViewModel()
    try viewModel.addDistance(RaceDistance(category: .custom(0.001), type: .inPerson))

    #expect(viewModel.distances.count == 1)
  }
}
