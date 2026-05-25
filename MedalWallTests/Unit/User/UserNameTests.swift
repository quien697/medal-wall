//
//  UserNameTests.swift
//  MedalWall
//
//  Created by Quien on 2025-12-07.
//

import Testing

@testable import MedalWall

struct UserNameTests {

  @Test("Full name concatenates first and last name with a space")
  func testFormattedFullName() {
    let name = UserName(firstName: "Tsung-Hsun", lastName: "Liu")

    #expect(name.fullName == "Tsung-Hsun Liu")
  }

  @Test("Full name preserves internal spaces in first name")
  func testFormattedFullNameWithInternalSpace() {
    let name = UserName(firstName: "Tsung Hsun", lastName: "Liu")

    #expect(name.fullName == "Tsung Hsun Liu")
  }

  @Test("Trimming removes extra whitespace around names")
  func testFormattedFullNameWithExtraSpaces() {
    let name = UserName(firstName: "  Tsung Hsun", lastName: "Liu   ")

    #expect(name.trimmedFirstName == "Tsung Hsun")
    #expect(name.trimmedLastName == "Liu")
    #expect(name.fullName == "Tsung Hsun Liu")
  }

  @Test("Trimming removes newline characters from names")
  func testFormattedFullNameWithNewLines() {
    let name = UserName(firstName: "Tsung Hsun\n", lastName: "Liu")

    #expect(name.trimmedFirstName == "Tsung Hsun")
    #expect(name.trimmedLastName == "Liu")
    #expect(name.fullName == "Tsung Hsun Liu")
  }

  @Test("Full name falls back to Runner when both names are empty")
  func testFormattedFullNameBothEmpty() {
    let name = UserName(firstName: "", lastName: "")

    #expect(name.fullName == "Runner")
  }

  @Test("Full name uses only first name when last name is empty")
  func testFormattedFullNameOnlyFirst() {
    let name = UserName(firstName: "Tsung-Hsun", lastName: "")

    #expect(name.fullName == "Tsung-Hsun")
  }

  @Test("Full name uses only last name when first name is empty")
  func testFormattedFullNameOnlyLast() {
    let name = UserName(firstName: "", lastName: "Liu")

    #expect(name.fullName == "Liu")
  }
}
