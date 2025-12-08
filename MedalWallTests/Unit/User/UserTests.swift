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
  
  @Test("User initializes with correct stored properties")
  func testUserInit() {
    let user = User(
      name: .init(firstName: "Cruise", lastName: "Tom")
    )
    
    #expect(user.firstName == "Cruise")
    #expect(user.lastName == "Tom")
    #expect(user.avatarData == nil)
    #expect(user.bio == nil)
    #expect(user.gender == nil)
    #expect(user.birthday == nil)
    #expect(user.unit == MeasurementUnit.km.rawValue)
    #expect(user.medals.isEmpty)
  }
  
  @Test("Enum gender maps correctly from rawValue")
  func genderEnumMapsCorrectly() {
    let user = User(
      name: .init(firstName: "Cruise", lastName: "Tom")
    )
    
    #expect(user.genderEnum == .none)
    
    user.gender = Gender.male.rawValue
    #expect(user.genderEnum == .male)
    
    user.gender = Gender.female.rawValue
    #expect(user.genderEnum == .female)
  }
  
  @Test("Enum unit maps correctly from rawValue")
  func unitEnumMapsCorrectly() {
    let user = User(
      name: .init(firstName: "Cruise", lastName: "Tom")
    )
    
    #expect(user.unitEnum == .km)
    
    user.unit = MeasurementUnit.mi.rawValue
    #expect(user.unitEnum == .mi)
  }
  
  @Test("Avatar converts correctly from Data to UIImage")
  func avatarConversion() {
    let avatar = UIImage(named: "quien")
    let data = avatar?.jpegData(compressionQuality: 0.9)
    
    let user = User(
      name: .init(firstName: "Alice", lastName: "Smith"),
      avatarData: data
    )
    
    #expect(user.avatar != nil)
    #expect(user.avatar?.size == avatar?.size)
    #expect(user.avatar?.scale == avatar?.scale)
  }
  
  @Test("Avatar is nil when avatarData is nil")
  func avatarNil() {
    let user = User(
      name: .init(firstName: "Alice", lastName: "Smith")
    )
    
    #expect(user.avatarData == nil)
    #expect(user.avatar == nil)
  }
}
