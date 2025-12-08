//
//  UserNameTests.swift
//  MedalWall
//
//  Created by Quien on 2025-12-07.
//

import Testing
@testable import MedalWall

struct UserNameTests {
  
  @Test("Formatted string includes district, city, province and country when all exist")
  func formattedFullName() {
    let user = UserName(firstName: "Tsung-Hsun", lastName: "Liu")
    
    #expect(user.fullName == "Tsung-Hsun, Liu")
  }
}
