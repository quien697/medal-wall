//
//  MedalFaceTests.swift
//  MedalWall
//
//  Created by Quien on 2026-11-03.
//

import SwiftUI
import Testing

@testable import MedalWall

@MainActor
struct MedalFaceTests {

  @Test("each face is named for the catalog")
  func testTitle() {
    #expect(MedalFace.front.title == "Front")
    #expect(MedalFace.back.title == "Back")
  }

  @Test("each face names its empty slot and its photo")
  func testFaceWording() {
    #expect(MedalFace.front.addTitle == "Add front")
    #expect(MedalFace.back.addTitle == "Add back")
    #expect(MedalFace.front.photoTitle == "Front photo")
    #expect(MedalFace.back.photoTitle == "Back photo")
  }

  @Test("the faces come front first, the order the form and the details show them in")
  func testOrder() {
    #expect(MedalFace.allCases == [.front, .back])
  }
}
