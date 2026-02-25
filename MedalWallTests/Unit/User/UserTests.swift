//
//  UserTests.swift
//  MedalWall
//
//  Created by Quien on 2025-12-08.
//

import Testing
import UIKit
@testable import MedalWall

struct UserTests {
  
  @Test("")
  func testInitWithDefaults() {
    let user = User()
    
    #expect(user.firstName == "")
    #expect(user.lastName == "")
    #expect(user.fullName == "Runner")
    #expect(user.avatarData == nil)
    #expect(user.cropAvatarData == nil)
    #expect(user.bio == nil)
    #expect(user.gender == nil)
    #expect(user.birthday == nil)
    #expect(user.isGuest == false)
  }
  
  @Test("init assigns first and last name from UserName")
  func testInitUserName() {
    let name = UserName(firstName: "  Alice ", lastName: "Smith ")
    let user = User(name: name)
    
    #expect(user.firstName == "Alice")
    #expect(user.lastName == "Smith")
  }
  
  @Test("init converts Gender enum to rawValue string")
  func testInitGender() {
    let user = User(gender: .male)
    #expect(user.gender == "male")
  }
}
