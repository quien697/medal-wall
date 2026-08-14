//
//  LocalizedDisplayStringTests.swift
//  MedalWall
//
//  Created by Quien on 2026-08-11.
//

import Foundation
import Testing

@testable import MedalWall

/// Display strings built outside a SwiftUI `body` cannot read `\.locale` from the
/// environment, so they resolve through `String.appLocalized`.
///
/// Each property is checked in two halves, neither of which touches
/// `UserDefaults.standard` — mutating it here would race with the suites that read
/// these same properties in parallel:
///  1. the property returns its English source string, and
///  2. the catalog key it is built from carries the expected `zh-TW` translation.
///
/// `LocalizationTests` closes the chain by proving `appLocalized` selects the `zh-TW`
/// table, and `StringCatalogTests` guards the integrity of the compiled table itself.
struct LocalizedDisplayStringTests {

  // MARK: - Support
  private static let zhTW: UserDefaults = {
    let suiteName = "LocalizedDisplayStringTests.zh-TW"
    guard let defaults = UserDefaults(suiteName: suiteName) else {
      fatalError("Unable to create UserDefaults suite")
    }
    defaults.set(AppLanguage.zhTW.rawValue, forKey: AppLanguage.storageKey)

    return defaults
  }()

  /// The `zh-TW` rendering of a catalog key, resolved without touching global state.
  private func translated(_ key: String.LocalizationValue) -> String {
    String.appLocalized(key, defaults: Self.zhTW)
  }

  // MARK: - Gender
  @Test("Gender display name is catalog-backed and translated")
  func testGenderDisplayName() {
    #expect(Gender.male.displayName == "Male")
    #expect(Gender.female.displayName == "Female")
    #expect(translated("Male") == "男子")
    #expect(translated("Female") == "女子")
  }

  @Test("Gender short name is catalog-backed and translated")
  func testGenderShortName() {
    #expect(Gender.male.shortName == "M")
    #expect(Gender.female.shortName == "F")
    #expect(translated("M") == "男")
    #expect(translated("F") == "女")
  }

  // MARK: - AgeGroup
  @Test("Open-ended age group brackets are catalog-backed and translated")
  func testOpenEndedAgeGroupDisplayName() {
    #expect(AgeGroup.under20.displayName == "Under 20")
    #expect(AgeGroup.over80.displayName == "80+")
    #expect(translated("Under 20") == "20以下")
    #expect(translated("80+") == "80以上")
  }

  @Test("Numeric age group brackets are locale-invariant")
  func testNumericAgeGroupDisplayName() {
    #expect(AgeGroup.from30to34.displayName == "30–34")
    #expect(AgeGroup.from60to69.displayName == "60–69")
  }

  // MARK: - Division
  @Test("Division display name composes gender and age group")
  func testDivisionDisplayName() {
    let division = Division(gender: .male, ageGroup: .from30to34)

    #expect(division.displayName == "M 30–34")
  }

  // MARK: - RaceDistanceType
  /// Race distance types are deliberately not translated — they stay in the source
  /// form under every language.
  @Test("Race distance type display names are not translated")
  func testRaceDistanceTypeDisplayName() {
    #expect(RaceDistanceType.inPerson.displayName == "In-person")
    #expect(RaceDistanceType.virtual.displayName == "Virtual")
    #expect(RaceDistanceType.wheelChair.displayName == "Wheel Chair")
    #expect(translated("In-person") == "In-person")
    #expect(translated("Virtual") == "Virtual")
    #expect(translated("Wheel Chair") == "Wheel Chair")
  }

  @Test("Race distance label composes a type with a numeric distance")
  func testRaceDistanceDisplayLabel() {
    #expect(RaceDistance(category: .half, type: .virtual).displayLabel == "Virtual Half")
    #expect(RaceDistance(category: .full, type: .inPerson).displayLabel == "Full")
  }

  // MARK: - AchievementTier
  @Test("Achievement tier names are catalog-backed and translated")
  func testAchievementTierName() {
    #expect(AchievementTier.firstFinish.name == "First Finish")
    #expect(AchievementTier.centurion.name == "Centurion")
    #expect(translated("First Finish") == "初次完賽")
    #expect(translated("Centurion") == "百馬達成")
  }

  // MARK: - ItemEditMode
  @Test("Item edit mode display name is catalog-backed and translated")
  func testItemEditModeDisplayName() {
    #expect(ItemEditMode.add.displayName == "New")
    #expect(ItemEditMode.edit.displayName == "Edit")
    #expect(translated("New") == "新增")
    #expect(translated("Edit") == "編輯")
  }

  // MARK: - AppTheme
  @Test("App theme labels are catalog-backed and translated")
  func testAppThemeLabel() {
    #expect(AppTheme.system.label == "System")
    #expect(AppTheme.light.label == "Light")
    #expect(AppTheme.dark.label == "Dark")
    #expect(translated("Light") == "淺色")
    #expect(translated("Dark") == "深色")
  }

  // MARK: - AppLanguage
  @Test("Language names stay in their own script and are never translated")
  func testAppLanguageLabel() {
    #expect(AppLanguage.english.label == "English")
    #expect(AppLanguage.zhTW.label == "繁體中文")
    #expect(translated("System") == "系統")
  }

  // MARK: - UserName
  @Test("The anonymous user fallback name is catalog-backed and translated")
  func testUserNameFallback() {
    #expect(UserName(firstName: "", lastName: "").fullName == "Runner")
    #expect(translated("Runner") == "跑者")
  }

  @Test("An entered user name is never translated")
  func testEnteredUserNameIsNotTranslated() {
    #expect(UserName(firstName: "Runner", lastName: "").fullName == "Runner")
    #expect(UserName(firstName: "王", lastName: "小明").fullName == "王 小明")
  }

  // MARK: - AppError
  @Test("Error title, message, and guidance are catalog-backed and translated")
  func testAppErrorStrings() {
    let error = AppError.raceSaveFailed

    #expect(error.title == "Race Save Failed")
    #expect(error.message == "We couldn't save your race event.")
    #expect(error.guidance == "Please try it again.")
    #expect(translated("Race Save Failed") == "賽事儲存失敗")
    #expect(translated("We couldn't save your race event.") == "我們無法儲存你的賽事。")
    #expect(translated("Please try it again.") == "請再試一次。")
  }

  @Test("A server description is interpolated into the message, not translated")
  func testAppErrorInterpolatedMessage() {
    let message = AppError.raceFetchFailed("network down").message

    #expect(message == "We couldn't load your races. network down")
    #expect(
      translated("We couldn't load your races. \("network down")")
        == "我們無法載入你的賽事。network down"
    )
  }
}
