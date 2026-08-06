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

  @Test("averagePaceText formats pace as M'SS\" /km for a full marathon")
  func testAveragePaceTextFormatted() {
    // 12624s over 42.195km → pace ≈ 4.9864 min/km → "4'59\" /km"
    let viewModel = MedalDetailViewModel(medal: makeMedal(finishTime: 12624))

    #expect(viewModel.averagePaceText == "4'59\" /km")
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
