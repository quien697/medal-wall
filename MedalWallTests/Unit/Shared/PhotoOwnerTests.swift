//
//  PhotoOwnerTests.swift
//  MedalWall
//
//  Created by Quien on 2026-10-10.
//

import Testing

@testable import MedalWall

struct PhotoOwnerTests {

  // MARK: - User
  @Test("a user owns their avatars, including the one stored before unique names")
  func testUserOwnsAvatars() {
    let owner = PhotoOwner.user(uid: "uid-a")

    #expect(owner.owns(path: "users/uid-a/avatar/3F2A.jpg"))
    #expect(owner.owns(path: "users/uid-a/avatar/profile.jpg"))
  }

  @Test("a user does not own another user's avatar or their own medal photos")
  func testUserDoesNotOwnOthers() {
    let owner = PhotoOwner.user(uid: "uid-a")

    #expect(!owner.owns(path: "users/uid-b/avatar/3F2A.jpg"))
    #expect(!owner.owns(path: "users/uid-a/medals/medal-a/cover/3F2A.jpg"))
  }

  // MARK: - Race
  @Test("a race owns its logos, including the one stored before unique names")
  func testRaceOwnsLogos() {
    let owner = PhotoOwner.race(raceId: "race-a")

    #expect(owner.owns(path: "races/race-a/raceLogo/3F2A.jpg"))
    #expect(owner.owns(path: "races/race-a/logo.jpg"))
  }

  @Test("a race does not own its editions' logos, another race's or a user's photos")
  func testRaceDoesNotOwnOthers() {
    let owner = PhotoOwner.race(raceId: "race-a")

    #expect(!owner.owns(path: "races/race-a/editions/edition-a/editionLogo/3F2A.jpg"))
    #expect(!owner.owns(path: "races/race-ab/raceLogo/3F2A.jpg"))
    #expect(!owner.owns(path: "users/uid-a/avatar/3F2A.jpg"))
  }

  // MARK: - Edition
  @Test("an edition owns its logos, including the one stored before unique names")
  func testEditionOwnsLogos() {
    let owner = PhotoOwner.edition(raceId: "race-a", editionId: "edition-a")

    #expect(owner.owns(path: "races/race-a/editions/edition-a/editionLogo/3F2A.jpg"))
    #expect(owner.owns(path: "races/race-a/editions/edition-a/logo.jpg"))
  }

  @Test("an edition does not own another edition's logo or its race's logo")
  func testEditionDoesNotOwnOthers() {
    let owner = PhotoOwner.edition(raceId: "race-a", editionId: "edition-a")

    #expect(!owner.owns(path: "races/race-a/editions/edition-b/editionLogo/3F2A.jpg"))
    #expect(!owner.owns(path: "races/race-a/raceLogo/3F2A.jpg"))
  }

  // MARK: - Medal
  @Test("a medal owns its cover and event photos, including the cover stored before unique names")
  func testMedalOwnsPhotos() {
    let owner = PhotoOwner.medal(userId: "uid-a", medalId: "medal-a")

    #expect(owner.owns(path: "users/uid-a/medals/medal-a/cover/3F2A.jpg"))
    #expect(owner.owns(path: "users/uid-a/medals/medal-a/eventPhotos/3F2A.jpg"))
    #expect(owner.owns(path: "users/uid-a/medals/medal-a/medal.jpg"))
  }

  @Test("a medal does not own another medal's photos or another user's")
  func testMedalDoesNotOwnOthers() {
    let owner = PhotoOwner.medal(userId: "uid-a", medalId: "medal-a")

    #expect(!owner.owns(path: "users/uid-a/medals/medal-b/cover/3F2A.jpg"))
    #expect(!owner.owns(path: "users/uid-b/medals/medal-a/cover/3F2A.jpg"))
    #expect(!owner.owns(path: "users/uid-a/avatar/3F2A.jpg"))
  }
}
