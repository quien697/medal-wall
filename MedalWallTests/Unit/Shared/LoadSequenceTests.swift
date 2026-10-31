//
//  LoadSequenceTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-30.
//

import Testing

@testable import MedalWall

struct LoadSequenceTests {

  @Test("an older load cannot apply once a newer one has")
  func testOlderLoadRefusedAfterNewerApplied() {
    var loads = LoadSequence()
    let older = loads.begin()
    let newer = loads.begin()

    let newerApplies = loads.shouldApply(newer)
    let olderApplies = loads.shouldApply(older)

    #expect(newerApplies)
    #expect(!olderApplies)
  }

  @Test("an older load applies while no newer one has, and the newer one still applies after")
  func testOlderLoadAppliesFirst() {
    var loads = LoadSequence()
    let older = loads.begin()
    let newer = loads.begin()

    let olderApplies = loads.shouldApply(older)
    let newerApplies = loads.shouldApply(newer)

    #expect(olderApplies)
    #expect(newerApplies)
  }

  @Test("a load may apply in steps")
  func testLoadAppliesInSteps() {
    var loads = LoadSequence()
    let load = loads.begin()

    let firstStep = loads.shouldApply(load)
    let secondStep = loads.shouldApply(load)

    #expect(firstStep)
    #expect(secondStep)
  }

  @Test("only the newest started load is the newest")
  func testOnlyNewestStartedIsNewest() {
    var loads = LoadSequence()
    let older = loads.begin()
    let newer = loads.begin()

    #expect(!loads.isNewest(older))
    #expect(loads.isNewest(newer))
  }

  @Test("a load is the newest until another begins")
  func testLoadIsNewestUntilAnotherBegins() {
    var loads = LoadSequence()
    let first = loads.begin()

    #expect(loads.isNewest(first))
    _ = loads.begin()
    #expect(!loads.isNewest(first))
  }
}
