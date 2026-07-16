//
//  AchievementTierTests.swift
//  MedalWall
//
//  Created by Quien on 2026-07-14.
//

import Testing

@testable import MedalWall

struct AchievementTierTests {

  @Test("allCases is ordered ascending by threshold")
  func testAllCasesOrderedAscending() {
    let thresholds = AchievementTier.allCases.map { $0.threshold }

    #expect(thresholds == [1, 3, 5, 10, 25, 50, 100])
  }

  @Test("threshold matches each tier's raw value")
  func testThresholds() {
    #expect(AchievementTier.firstFinish.threshold == 1)
    #expect(AchievementTier.hatTrick.threshold == 3)
    #expect(AchievementTier.highFive.threshold == 5)
    #expect(AchievementTier.perfectTen.threshold == 10)
    #expect(AchievementTier.quarterCentury.threshold == 25)
    #expect(AchievementTier.halfCentury.threshold == 50)
    #expect(AchievementTier.centurion.threshold == 100)
  }

  @Test("name matches expected display string for each tier")
  func testNames() {
    #expect(AchievementTier.firstFinish.name == "First Finish")
    #expect(AchievementTier.hatTrick.name == "Hat Trick")
    #expect(AchievementTier.highFive.name == "High Five")
    #expect(AchievementTier.perfectTen.name == "Perfect Ten")
    #expect(AchievementTier.quarterCentury.name == "Quarter Century")
    #expect(AchievementTier.halfCentury.name == "Half Century")
    #expect(AchievementTier.centurion.name == "Centurion")
  }
}
