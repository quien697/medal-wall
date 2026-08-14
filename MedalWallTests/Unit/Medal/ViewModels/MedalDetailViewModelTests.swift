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
    distance: RaceDistance = RaceDistance(category: .full, type: .inPerson),
    finishTime: TimeInterval? = nil,
    overallPlacement: Int? = nil,
    totalParticipants: Int? = nil,
    division: Division? = nil,
    divisionPlacement: Int? = nil,
    divisionTotal: Int? = nil,
    genderPlacement: Int? = nil,
    genderTotal: Int? = nil
  ) -> Medal {
    Medal(
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
      userID: "u1"
    )
  }

  // MARK: - finishTimeText
  @Test("finishTimeText is dash when finishTime is nil")
  func testFinishTimeTextNil() {
    let medal = makeMedal()
    let viewModel = MedalDetailViewModel(medal: medal)

    #expect(viewModel.finishTimeText == "-")
  }

  @Test("finishTimeText formats seconds as HH:MM:SS")
  func testFinishTimeTextFormatted() {
    // 3h 30m 24s = 12624s → "03:30:24"
    let viewModel = MedalDetailViewModel(medal: makeMedal(finishTime: 3 * 3600 + 30 * 60 + 24))

    #expect(viewModel.finishTimeText == "03:30:24")
  }

  // MARK: - averagePaceText
  @Test("averagePaceText is placeholder when finishTime is nil")
  func testAveragePaceTextNil() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(finishTime: nil))

    #expect(viewModel.averagePaceText == "--'-- \"")
  }

  @Test("averagePaceText formats pace as M'SS\" for a full marathon")
  func testAveragePaceTextFormatted() {
    // 12624s over 42.195km → pace ≈ 4.9864 min/km → "4'59\" /km"
    let viewModel = MedalDetailViewModel(medal: makeMedal(finishTime: 12624))
    let expected = MedalDetailViewModel.paceText(
      minutesPerKilometer: 12624 / 60 / 42.195,
      in: DistanceUnit.resolved()
    )

    #expect(viewModel.averagePaceText == expected)
  }

  @Test("Pace is expressed per kilometre in kilometres mode")
  func testPaceTextKilometers() {
    let pace = 5 + 41.0 / 60

    #expect(
      MedalDetailViewModel.paceText(
        minutesPerKilometer: pace,
        in: .kilometers,
        defaults: Self.makeDefaults()
      ) == "5'41\" /km"
    )
  }

  @Test("Pace is expressed per mile in miles mode")
  func testPaceTextMiles() {
    let pace = 5 + 41.0 / 60

    #expect(
      MedalDetailViewModel.paceText(
        minutesPerKilometer: pace,
        in: .miles,
        defaults: Self.makeDefaults()
      ) == "9'08\" /mi"
    )
  }

  @Test("Pace is the placeholder when there is no pace to show")
  func testPaceTextNil() {
    #expect(
      MedalDetailViewModel.paceText(
        minutesPerKilometer: nil,
        in: .miles,
        defaults: Self.makeDefaults()
      ) == "--'-- \""
    )
  }

  // MARK: - distanceText
  @Test("Hero shows a preset's name and measurement in kilometres")
  func testDistanceTextPresetKilometers() {
    #expect(Self.heroText(.full, in: .kilometers) == "Full · 42.2 km")
    #expect(Self.heroText(.half, in: .kilometers) == "Half · 21.1 km")
  }

  @Test("Hero shows a preset's name and measurement in miles")
  func testDistanceTextPresetMiles() {
    #expect(Self.heroText(.full, in: .miles) == "Full · 26.2 mi")
    #expect(Self.heroText(.tenKM, in: .miles) == "10K · 6.2 mi")
  }

  @Test("Hero keeps the redundant measurement for a 10K in kilometres")
  func testDistanceTextRedundant() {
    #expect(Self.heroText(.tenKM, in: .kilometers) == "10K · 10 km")
    #expect(Self.heroText(.fiveKM, in: .kilometers) == "5K · 5 km")
  }

  @Test("Hero shows a custom distance once, not twice")
  func testDistanceTextCustomNotRepeated() {
    #expect(Self.heroText(.custom(16.09344), in: .miles) == "10 mi")
    #expect(Self.heroText(.custom(16.09344), in: .kilometers) == "16.1 km")
  }

  private static func heroText(
    _ category: RaceDistanceCategory,
    in unit: DistanceUnit,
    function: String = #function
  ) -> String {
    MedalDetailViewModel.heroDistanceText(
      for: category,
      in: unit,
      defaults: makeDefaults(function: function)
    )
  }

  // MARK: - overallPlacementText
  @Test("overallPlacementText is dash when overallPlacement is nil")
  func testOverallPlacementTextNil() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(overallPlacement: nil))

    #expect(viewModel.overallPlacementText == "-")
  }

  @Test("overallPlacementText returns the placement as a string")
  func testOverallPlacementTextValue() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(overallPlacement: 1058))

    #expect(viewModel.overallPlacementText == "1058")
  }

  // MARK: - totalParticipantsText
  @Test("totalParticipantsText is empty string when totalParticipants is nil")
  func testTotalParticipantsTextNil() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(totalParticipants: nil))

    #expect(viewModel.totalParticipantsText.isEmpty)
  }

  @Test("totalParticipantsText returns 'of N' when totalParticipants is set")
  func testTotalParticipantsTextValue() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(totalParticipants: 7373))

    #expect(viewModel.totalParticipantsText == "of 7373")
  }

  // MARK: - divisionText
  @Test("divisionText is dash when division is nil")
  func testDivisionTextNil() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(division: nil))

    #expect(viewModel.divisionText == "-")
  }

  @Test("divisionText returns the division display name when set")
  func testDivisionTextValue() {
    let division = Division(gender: .male, ageGroup: .from30to34)
    let viewModel = MedalDetailViewModel(medal: makeMedal(division: division))

    #expect(viewModel.divisionText == division.displayName)
  }

  // MARK: - divisionPlacementText
  @Test("divisionPlacementText is dash when divisionPlacement is nil")
  func testDivisionPlacementTextNil() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(divisionPlacement: nil))

    #expect(viewModel.divisionPlacementText == "-")
  }

  @Test("divisionPlacementText returns the placement as a string")
  func testDivisionPlacementTextValue() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(divisionPlacement: 523))

    #expect(viewModel.divisionPlacementText == "523")
  }

  // MARK: - divisionTotalText
  @Test("divisionTotalText is empty string when divisionTotal is nil")
  func testDivisionTotalTextNil() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(divisionTotal: nil))

    #expect(viewModel.divisionTotalText.isEmpty)
  }

  @Test("divisionTotalText returns 'of N' when divisionTotal is set")
  func testDivisionTotalTextValue() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(divisionTotal: 1633))

    #expect(viewModel.divisionTotalText == "of 1633")
  }

  // MARK: - genderPlacementText
  @Test("genderPlacementText is dash when genderPlacement is nil")
  func testGenderPlacementTextNil() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(genderPlacement: nil))

    #expect(viewModel.genderPlacementText == "-")
  }

  @Test("genderPlacementText returns the placement as a string")
  func testGenderPlacementTextValue() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(genderPlacement: 233))

    #expect(viewModel.genderPlacementText == "233")
  }

  // MARK: - genderTotalText
  @Test("genderTotalText is empty string when genderTotal is nil")
  func testGenderTotalTextNil() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(genderTotal: nil))

    #expect(viewModel.genderTotalText.isEmpty)
  }

  @Test("genderTotalText returns 'of N' when genderTotal is set")
  func testGenderTotalTextValue() {
    let viewModel = MedalDetailViewModel(medal: makeMedal(genderTotal: 6081))

    #expect(viewModel.genderTotalText == "of 6081")
  }
}
