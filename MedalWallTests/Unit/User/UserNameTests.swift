//
//  UserNameTests.swift
//  MedalWall
//
//  Created by Quien on 2025-12-07.
//

import Testing
@testable import MedalWall

struct UserNameTests {
  
  @Test("Full name concatenates first and last name with comma separator")
  func testFormattedFullName() {
    let user = UserName(firstName: "Tsung-Hsun", lastName: "Liu")
    
    #expect(user.fullName == "Tsung-Hsun, Liu")
  }
  
  @Test("Full name preserves internal spaces in first name")
  func testFormattedFullNameWithInternalSpace() {
    let user = UserName(firstName: "Tsung Hsun", lastName: "Liu")
    
    #expect(user.fullName == "Tsung Hsun, Liu")
  }
  
  @Test("Trimming removes extra whitespace around names")
  func testFormattedFullNameWithExtraSpaces() {
    let user = UserName(firstName: "  Tsung Hsun", lastName: "Liu   ")
    
    #expect(user.trimmedFirstName == "Tsung Hsun")
    #expect(user.trimmedLastName == "Liu")
    #expect(user.fullName == "Tsung Hsun, Liu")
  }
  
  @Test("Trimming removes newline characters from names")
  func testFormattedFullNamewithNewLines() {
    let user = UserName(firstName: "Tsung Hsun\n", lastName: "Liu")
    
    #expect(user.trimmedFirstName == "Tsung Hsun")
    #expect(user.trimmedLastName == "Liu")
    #expect(user.fullName == "Tsung Hsun, Liu")
  }
}
