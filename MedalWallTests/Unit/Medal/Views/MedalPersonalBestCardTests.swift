//
//  MedalPersonalBestCardTests.swift
//  MedalWall
//
//  Created by Quien on 2026-09-08.
//

import Testing

@testable import MedalWall

struct MedalPersonalBestCardTests {

  @Test("The current page lights its own dot")
  func testLitPageInRange() {
    #expect(MedalPersonalBestCard.litPage(currentPage: 0, pageCount: 3) == 0)
    #expect(MedalPersonalBestCard.litPage(currentPage: 1, pageCount: 3) == 1)
    #expect(MedalPersonalBestCard.litPage(currentPage: 2, pageCount: 3) == 2)
  }

  /// An out-of-range page would otherwise leave every dot dimmed.
  @Test("A page past the last dot clamps to the last dot")
  func testLitPagePastEnd() {
    #expect(MedalPersonalBestCard.litPage(currentPage: 7, pageCount: 3) == 2)
  }

  @Test("A negative page clamps to the first dot")
  func testLitPageNegative() {
    #expect(MedalPersonalBestCard.litPage(currentPage: -4, pageCount: 3) == 0)
  }

  @Test("An empty or negative page count resolves without going below zero")
  func testLitPageWithoutPages() {
    #expect(MedalPersonalBestCard.litPage(currentPage: 0, pageCount: 0) == 0)
    #expect(MedalPersonalBestCard.litPage(currentPage: 2, pageCount: -5) == 0)
  }

  @Test("A single page lights the only dot")
  func testLitPageSinglePage() {
    #expect(MedalPersonalBestCard.litPage(currentPage: 0, pageCount: 1) == 0)
    #expect(MedalPersonalBestCard.litPage(currentPage: 3, pageCount: 1) == 0)
  }
}
