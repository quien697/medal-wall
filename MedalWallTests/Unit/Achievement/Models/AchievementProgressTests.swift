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
    let progress = AchievementProgress.compute(persistedMilestone: 0, liveCount: 0)

    #expect(progress.unlockedTier == nil)
    #expect(progress.nextTier == .firstFinish)
    #expect(progress.currentCount == 0)
    #expect(progress.isMaxed == false)
  }

  @Test("compute exactly at a threshold unlocks that tier")
  func testComputeExactlyAtThreshold() {
    let progress = AchievementProgress.compute(persistedMilestone: 0, liveCount: 1)

    #expect(progress.unlockedTier == .firstFinish)
    #expect(progress.nextTier == .hatTrick)
    #expect(progress.currentCount == 1)
  }

  @Test("compute between thresholds unlocks the lower tier")
  func testComputeBetweenThresholds() {
    let progress = AchievementProgress.compute(persistedMilestone: 0, liveCount: 7)

    #expect(progress.unlockedTier == .highFive)
    #expect(progress.nextTier == .perfectTen)
    #expect(progress.currentCount == 7)
  }

  @Test("compute at the max tier has no next tier and is maxed")
  func testComputeMaxed() {
    let progress = AchievementProgress.compute(persistedMilestone: 100, liveCount: 100)

    #expect(progress.unlockedTier == .centurion)
    #expect(progress.nextTier == nil)
    #expect(progress.isMaxed == true)
  }

  @Test("compute keeps the persisted tier when live count has dropped below it")
  func testComputePersistedHigherThanLive() {
    let progress = AchievementProgress.compute(persistedMilestone: 10, liveCount: 7)

    #expect(progress.unlockedTier == .perfectTen)
    #expect(progress.nextTier == .quarterCentury)
    #expect(progress.currentCount == 7)
  }

  @Test("compute reflects a live count not yet ratcheted into the persisted value")
  func testComputeLiveHigherThanPersisted() {
    let progress = AchievementProgress.compute(persistedMilestone: 0, liveCount: 12)

    #expect(progress.unlockedTier == .perfectTen)
    #expect(progress.nextTier == .quarterCentury)
    #expect(progress.currentCount == 12)
  }

  @Test("compute clamps negative inputs to zero")
  func testComputeClampsNegativeInputs() {
    let progress = AchievementProgress.compute(persistedMilestone: -5, liveCount: -3)

    #expect(progress.unlockedTier == nil)
    #expect(progress.nextTier == .firstFinish)
    #expect(progress.currentCount == 0)
    #expect(progress.isMaxed == false)
  }

  @Test("compute clamps a negative live count while keeping the persisted tier")
  func testComputeClampsNegativeLiveCount() {
    let progress = AchievementProgress.compute(persistedMilestone: 10, liveCount: -3)

    #expect(progress.unlockedTier == .perfectTen)
    #expect(progress.nextTier == .quarterCentury)
    #expect(progress.currentCount == 0)
  }

  @Test("compute past the max tier keeps the live count and stays maxed")
  func testComputeAboveMaxKeepsCount() {
    let progress = AchievementProgress.compute(persistedMilestone: 100, liveCount: 120)

    #expect(progress.unlockedTier == .centurion)
    #expect(progress.nextTier == nil)
    #expect(progress.currentCount == 120)
    #expect(progress.isMaxed == true)
  }

  // MARK: - ratchetedMilestone
  @Test("ratchetedMilestone never decreases the persisted value")
  func testRatchetNeverDecreases() {
    let result = AchievementProgress.ratchetedMilestone(persisted: 10, liveCount: 7)

    #expect(result == 10)
  }

  @Test("ratchetedMilestone bumps the persisted value up when live count crosses a new tier")
  func testRatchetBumpsUp() {
    let result = AchievementProgress.ratchetedMilestone(persisted: 0, liveCount: 12)

    #expect(result == 10)
  }

  @Test("ratchetedMilestone is a no-op when live count hasn't crossed a new tier")
  func testRatchetNoOp() {
    let result = AchievementProgress.ratchetedMilestone(persisted: 5, liveCount: 7)

    #expect(result == 5)
  }

  @Test("ratchetedMilestone is zero when there are no medals yet")
  func testRatchetZeroMedals() {
    let result = AchievementProgress.ratchetedMilestone(persisted: 0, liveCount: 0)

    #expect(result == 0)
  }

  @Test("ratchetedMilestone clamps negative inputs to zero")
  func testRatchetClampsNegativeInputs() {
    let result = AchievementProgress.ratchetedMilestone(persisted: -5, liveCount: -3)

    #expect(result == 0)
  }

  // MARK: - progressFraction
  @Test("progressFraction measures the live count against the next tier")
  func testFractionTowardNextTier() {
    let progress = AchievementProgress.compute(persistedMilestone: 0, liveCount: 7)

    #expect(progress.progressFraction == 0.7)
  }

  @Test("progressFraction is zero before the first medal")
  func testFractionNotStarted() {
    let progress = AchievementProgress.compute(persistedMilestone: 0, liveCount: 0)

    #expect(progress.progressFraction == 0)
  }

  @Test("progressFraction is full once a maxed track is reached")
  func testFractionMaxed() {
    let progress = AchievementProgress.compute(persistedMilestone: 100, liveCount: 100)

    #expect(progress.progressFraction == 1)
  }

  @Test("progressFraction clamps a count past the final threshold to one")
  func testFractionClampsPastFinalThreshold() {
    let progress = AchievementProgress.compute(persistedMilestone: 100, liveCount: 120)

    #expect(progress.progressFraction == 1)
  }

  @Test("progressFraction clamps a negative live count to zero")
  func testFractionClampsNegativeCount() {
    let progress = AchievementProgress.compute(persistedMilestone: 0, liveCount: -3)

    #expect(progress.progressFraction == 0)
  }
}
