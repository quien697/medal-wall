//
//  MedalDetailViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2026-05-29.
//

import Foundation
import Testing

@testable import MedalWall

struct MedalDetailViewModelTests {

  /// A throwaway `UserDefaults` suite pinning English, so number formatting does not
  /// vary with the simulator's region and `.standard` is never mutated.
  private static func makeDefaults(function: String = #function) -> UserDefaults {
    let suiteName = "MedalDetailViewModelTests.\(function).\(UUID().uuidString)"
    guard let defaults = UserDefaults(suiteName: suiteName) else {
      fatalError("Unable to create UserDefaults suite")
    }
    defaults.removePersistentDomain(forName: suiteName)
    defaults.set(AppLanguage.english.rawValue, forKey: AppLanguage.storageKey)

    return defaults
  }

  private func makeMedal(
    id: String = UUID().uuidString,
    distance: RaceDistance = RaceDistance(category: .full, type: .inPerson),
    finishTime: TimeInterval? = nil,
    overallPlacement: Int? = nil,
    totalParticipants: Int? = nil,
    division: Division? = nil,
    divisionPlacement: Int? = nil,
    divisionTotal: Int? = nil,
    genderPlacement: Int? = nil,
    genderTotal: Int? = nil,
    note: String? = nil,
    eventPhotos: [EventPhoto] = []
  ) -> Medal {
    Medal(
      id: id,
      name: "Test",
      date: .now,
      bibNumber: "1",
      place: Place(countryCode: "CA", city: "Vancouver"),
      distance: distance,
      finishTime: finishTime,
      overallPlacement: overallPlacement,
      totalParticipants: totalParticipants,
      division: division,
      divisionPlacement: divisionPlacement,
      divisionTotal: divisionTotal,
      genderPlacement: genderPlacement,
      genderTotal: genderTotal,
      note: note,
      eventPhotos: eventPhotos,
      userID: "u1"
    )
  }

  // MARK: - The day
  @Test("A blank note is no note at all")
  func testNoteTextBlank() {
    #expect(MedalDetailViewModel(medal: makeMedal(note: nil)).noteText == nil)
    #expect(MedalDetailViewModel(medal: makeMedal(note: "")).noteText == nil)
    #expect(MedalDetailViewModel(medal: makeMedal(note: "   ")).noteText == nil)
  }

  @Test("A written note is kept")
  func testNoteTextWritten() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(note: "Strong negative split."))

    #expect(viewModel.noteText == "Strong negative split.")
  }

  @Test("The day is present when there is a note, photos, or both")
  func testHasDay() {
    let photo = EventPhoto(imageUrl: "https://example.com/1.jpg", sortOrder: 0)

    #expect(MedalDetailViewModel(medal: makeMedal(note: "Rained.")).hasDay)
    #expect(MedalDetailViewModel(medal: makeMedal(eventPhotos: [photo])).hasDay)
    #expect(MedalDetailViewModel(medal: makeMedal(note: "Rained.", eventPhotos: [photo])).hasDay)
  }

  @Test("The day is absent when the user kept nothing of it")
  func testHasDayAbsent() {
    #expect(!MedalDetailViewModel(medal: makeMedal(note: nil, eventPhotos: [])).hasDay)
    #expect(!MedalDetailViewModel(medal: makeMedal(note: "  ", eventPhotos: [])).hasDay)
  }

  // MARK: - isPersonalRecord
  @Test("A medal is not a record holder unless it is opened as one")
  func testIsPersonalRecordDefaultsToFalse() {
    let viewModel = MedalDetailViewModel(medal: makeMedal())

    #expect(!viewModel.isPersonalRecord)
  }

  /// The screen is handed one medal; whether it holds a record belongs to the collection,
  /// so whatever opened the screen supplies the live record set rather than a frozen bool.
  @Test("A record holder is opened as one")
  func testIsPersonalRecordSupplied() {
    let medal = makeMedal(id: "X", finishTime: 12624)
    let viewModel = MedalDetailViewModel(medal: medal, personalRecordIDs: ["X"])

    #expect(viewModel.isPersonalRecord)
  }

  /// The screen calls `reloadMedal()` after an edit, and a faster/slower time elsewhere in
  /// the collection can demote or promote this medal between reloads. `isPersonalRecord`
  /// has to follow the live set — otherwise a stale "PR" tag persists until the user pops
  /// the screen and re-enters.
  @Test("isPersonalRecord follows personalRecordIDs after the set changes")
  func testIsPersonalRecordFollowsPersonalRecordIDs() {
    let medal = makeMedal(id: "X")
    let viewModel = MedalDetailViewModel(medal: medal, personalRecordIDs: ["X"])

    #expect(viewModel.isPersonalRecord)

    viewModel.personalRecordIDs = ["Y"]

    #expect(!viewModel.isPersonalRecord)

    viewModel.personalRecordIDs = ["Y", "X"]

    #expect(viewModel.isPersonalRecord)
  }

  // MARK: - finishTimeText
  @Test("finishTimeText says no time was recorded when finishTime is nil")
  func testFinishTimeTextNil() {
    let medal = makeMedal()
    let viewModel = MedalDetailViewModel(medal: medal)

    #expect(viewModel.finishTimeText == "No time recorded")
  }

  @Test("finishTimeText formats seconds as HH:MM:SS")
  func testFinishTimeTextFormatted() {
    // 3h 30m 24s = 12624s → "03:30:24"
    let viewModel = MedalDetailViewModel(medal: makeMedal(finishTime: 3 * 3600 + 30 * 60 + 24))

    #expect(viewModel.finishTimeText == "03:30:24")
  }

  // MARK: - averagePace
  @Test("An unrecorded pace reads as unfilled, with no unit beside it")
  func testAveragePaceUnrecorded() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(finishTime: nil))

    #expect(viewModel.averagePaceValue == "—")
    #expect(viewModel.averagePaceUnit == nil)
  }

  @Test("A recorded pace splits into its value and its unit")
  func testAveragePaceSplit() {
    // 12624s over 42.195km → pace ≈ 4.9864 min/km → "4'59\"" and "/km"
    let viewModel = MedalDetailViewModel(medal: makeMedal(finishTime: 12624))
    let unit = DistanceUnit.resolved()
    let expected = unit.paceValueText(minutesPerKilometer: 12624 / 60 / 42.195)

    #expect(viewModel.averagePaceValue == expected)
    #expect(viewModel.averagePaceUnit == "/\(unit.abbreviation())")
  }

  @Test("Pace is expressed per kilometre in kilometres mode")
  func testPaceTextKilometers() {
    let pace = 5 + 41.0 / 60

    #expect(
      DistanceUnit.kilometers.paceText(
        minutesPerKilometer: pace,
        defaults: Self.makeDefaults()
      ) == "5'41\" /km"
    )
  }

  @Test("Pace is expressed per mile in miles mode")
  func testPaceTextMiles() {
    let pace = 5 + 41.0 / 60

    #expect(
      DistanceUnit.miles.paceText(
        minutesPerKilometer: pace,
        defaults: Self.makeDefaults()
      ) == "9'08\" /mi"
    )
  }

  @Test("Pace is the placeholder when there is no pace to show")
  func testPaceTextNil() {
    #expect(
      DistanceUnit.miles.paceText(
        minutesPerKilometer: nil,
        defaults: Self.makeDefaults()
      ) == "--'-- \""
    )
  }

  // MARK: - overallPlacementText
  @Test("overallPlacementText reads as unfilled when overallPlacement is nil")
  func testOverallPlacementTextNil() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(overallPlacement: nil))

    #expect(viewModel.overallPlacementText == "—")
  }

  @Test("overallPlacementText returns the placement as a string")
  func testOverallPlacementTextValue() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(overallPlacement: 1058))

    #expect(viewModel.overallPlacementText == "1058")
  }

  // MARK: - overallTotalText
  @Test("overallTotalText is absent when totalParticipants is nil")
  func testOverallTotalTextNil() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(totalParticipants: nil))

    #expect(viewModel.overallTotalText == nil)
  }

  @Test("overallTotalText states the field the placement ran against")
  func testOverallTotalTextValue() {
    let viewModel = MedalDetailViewModel(
      medal: makeMedal(overallPlacement: 1058, totalParticipants: 7373)
    )

    #expect(viewModel.overallTotalText == "/ 7373")
  }

  /// A total with no placement would otherwise render as "— / 7373".
  @Test("overallTotalText is absent when there is no placement to qualify")
  func testOverallTotalTextWithoutPlacement() {
    let viewModel = MedalDetailViewModel(
      medal: makeMedal(overallPlacement: nil, totalParticipants: 7373)
    )

    #expect(viewModel.overallPlacementText == "—")
    #expect(viewModel.overallTotalText == nil)
  }

  // MARK: - divisionLabel
  @Test("divisionLabel names the group the placement ran within")
  func testDivisionLabelWithGroup() {
    let division = Division(gender: .male, ageGroup: .from30to34)
    let viewModel = MedalDetailViewModel(medal: makeMedal(division: division))

    #expect(viewModel.divisionLabel.contains(division.displayName))
    #expect(viewModel.divisionLabel != division.displayName)
  }

  /// The field is still something the user can fill in, so it keeps its plain label.
  @Test("divisionLabel is the plain label when there is no group")
  func testDivisionLabelWithoutGroup() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(division: nil))

    #expect(viewModel.divisionLabel == "Division")
  }

  // MARK: - divisionPlacementText
  @Test("divisionPlacementText reads as unfilled when divisionPlacement is nil")
  func testDivisionPlacementTextNil() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(divisionPlacement: nil))

    #expect(viewModel.divisionPlacementText == "—")
  }

  @Test("divisionPlacementText returns the placement as a string")
  func testDivisionPlacementTextValue() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(divisionPlacement: 523))

    #expect(viewModel.divisionPlacementText == "523")
  }

  // MARK: - divisionTotalText
  @Test("divisionTotalText is absent when divisionTotal is nil")
  func testDivisionTotalTextNil() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(divisionTotal: nil))

    #expect(viewModel.divisionTotalText == nil)
  }

  @Test("divisionTotalText states the field the placement ran against")
  func testDivisionTotalTextValue() {
    let viewModel = MedalDetailViewModel(
      medal: makeMedal(divisionPlacement: 523, divisionTotal: 1633)
    )

    #expect(viewModel.divisionTotalText == "/ 1633")
  }

  // MARK: - genderPlacementText
  @Test("genderPlacementText reads as unfilled when genderPlacement is nil")
  func testGenderPlacementTextNil() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(genderPlacement: nil))

    #expect(viewModel.genderPlacementText == "—")
  }

  @Test("genderPlacementText returns the placement as a string")
  func testGenderPlacementTextValue() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(genderPlacement: 233))

    #expect(viewModel.genderPlacementText == "233")
  }

  // MARK: - genderTotalText
  @Test("genderTotalText is absent when genderTotal is nil")
  func testGenderTotalTextNil() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(genderTotal: nil))

    #expect(viewModel.genderTotalText == nil)
  }

  @Test("genderTotalText states the field the placement ran against")
  func testGenderTotalTextValue() {
    let viewModel = MedalDetailViewModel(
      medal: makeMedal(genderPlacement: 233, genderTotal: 6081)
    )

    #expect(viewModel.genderTotalText == "/ 6081")
  }
}
