//
//  AchievementProgressTests.swift
//  MedalWall
//
//  Created by Quien on 2026-07-14.
//

import Testing

@testable import MedalWall

struct AchievementProgressTests {

  // MARK: - compute
  @Test("compute with zero medals shows no unlocked tier and First Finish as next")
  func testComputeZeroMedals() {
    let progress = AchievementProgress.compute(liveCount: 0)

    #expect(progress.unlockedTier == nil)
    #expect(progress.nextTier == .firstFinish)
    #expect(progress.currentCount == 0)
    #expect(progress.isMaxed == false)
  }

  @Test("compute exactly at a threshold unlocks that tier")
  func testComputeExactlyAtThreshold() {
    let progress = AchievementProgress.compute(liveCount: 1)

    #expect(progress.unlockedTier == .firstFinish)
    #expect(progress.nextTier == .hatTrick)
    #expect(progress.currentCount == 1)
  }

  @Test("compute between thresholds unlocks the lower tier")
  func testComputeBetweenThresholds() {
    let progress = AchievementProgress.compute(liveCount: 7)

    #expect(progress.unlockedTier == .highFive)
    #expect(progress.nextTier == .perfectTen)
    #expect(progress.currentCount == 7)
  }

  @Test("compute at the max tier has no next tier and is maxed")
  func testComputeMaxed() {
    let progress = AchievementProgress.compute(liveCount: 100)

    #expect(progress.unlockedTier == .centurion)
    #expect(progress.nextTier == nil)
    #expect(progress.isMaxed == true)
  }

  @Test("compute takes the tier from the live count alone")
  func testComputeTierFromLiveCount() {
    let progress = AchievementProgress.compute(liveCount: 4)

    #expect(progress.unlockedTier == .hatTrick)
    #expect(progress.nextTier == .highFive)
    #expect(progress.currentCount == 4)
  }

  @Test("compute clamps a negative live count to zero")
  func testComputeClampsNegativeInputs() {
    let progress = AchievementProgress.compute(liveCount: -3)

    #expect(progress.unlockedTier == nil)
    #expect(progress.nextTier == .firstFinish)
    #expect(progress.currentCount == 0)
    #expect(progress.isMaxed == false)
  }

  @Test("compute past the max tier keeps the live count and stays maxed")
  func testComputeAboveMaxKeepsCount() {
    let progress = AchievementProgress.compute(liveCount: 120)

    #expect(progress.unlockedTier == .centurion)
    #expect(progress.nextTier == nil)
    #expect(progress.currentCount == 120)
    #expect(progress.isMaxed == true)
  }

  // MARK: - progressFraction
  @Test("progressFraction measures the live count against the next tier")
  func testFractionTowardNextTier() {
    let progress = AchievementProgress.compute(liveCount: 7)

    #expect(progress.progressFraction == 0.7)
  }

  @Test("progressFraction is zero before the first medal")
  func testFractionNotStarted() {
    let progress = AchievementProgress.compute(liveCount: 0)

    #expect(progress.progressFraction == 0)
  }

  @Test("progressFraction is full once a maxed track is reached")
  func testFractionMaxed() {
    let progress = AchievementProgress.compute(liveCount: 100)

    #expect(progress.progressFraction == 1)
  }

  @Test("progressFraction clamps a count past the final threshold to one")
  func testFractionClampsPastFinalThreshold() {
    let progress = AchievementProgress.compute(liveCount: 120)

    #expect(progress.progressFraction == 1)
  }

  @Test("progressFraction clamps a negative live count to zero")
  func testFractionClampsNegativeCount() {
    let progress = AchievementProgress.compute(liveCount: -3)

    #expect(progress.progressFraction == 0)
  }
}
