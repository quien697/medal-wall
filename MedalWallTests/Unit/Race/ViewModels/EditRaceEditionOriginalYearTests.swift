//
//  EditRaceEditionOriginalYearTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-30.
//

import Testing

@testable import MedalWall

@MainActor
struct EditRaceEditionOriginalYearTests {

  @Test("originalYear keeps a saved edition's year while its year is edited")
  func testOriginalYearIgnoresEditedYear() {
    let viewModel = EditRaceEditionViewModel(
      mode: .edit, raceId: "race-taipei", edition: .taipei2019)

    viewModel.updateYear(2020)

    #expect(viewModel.originalYear == 2019)
  }

  @Test("originalYear keeps a staged edition's year while its year is edited")
  func testOriginalYearIgnoresEditedYearOfStagedEdition() {
    let staged = DraftRaceEdition(from: .taipei2025)
    let viewModel = EditRaceEditionViewModel(
      mode: .edit, raceId: "race-taipei", edition: nil, draft: staged)

    viewModel.updateYear(2026)

    #expect(viewModel.originalYear == 2025)
  }
}
