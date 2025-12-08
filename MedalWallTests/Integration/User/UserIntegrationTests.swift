//
//  UserIntegrationTests.swift
//  MedalWall
//
//  Created by Quien on 2025-12-08.
//

import Testing
import UIKit
import SwiftData
@testable import MedalWall

struct UserIntegrationTests {
  
  @Test("User persists into SwiftData and retrieves correctly")
  func testUserPersistence() throws {
    let schema = Schema([User.self])
    let context = try TestModelContainer.makeContext(with: schema)
    
    // test before
    let users = try context.fetch(FetchDescriptor<User>())
    #expect(users.count == 0)
    
    let user = User(
      name: .init(firstName: "Cruise", lastName: "Tom"),
      gender: .male,
    )
    context.insert(user)
    
    // test after
    let fetchedUsers = try context.fetch(FetchDescriptor<User>())
    #expect(fetchedUsers.count == 1)
    
    let fetchedUser = fetchedUsers.first!
    #expect(fetchedUser.firstName == "Cruise")
    #expect(fetchedUser.lastName == "Tom")
    #expect(fetchedUser.gender == Gender.male.rawValue)
  }
  
  @Test("Race updates correctly and persists changes")
  func testUserEdit() throws {
    let schema = Schema([User.self])
    let context = try TestModelContainer.makeContext(with: schema)
    
    let initUser = User(
      name: .init(firstName: "Cruise", lastName: "Tom"),
      gender: .female,
      birthday: DateComponents(calendar: .current, year: 2025, month: 12, day: 21).date!,
    )
    context.insert(initUser)
    
    // test before
    let users = try context.fetch(FetchDescriptor<User>())
    #expect(users.count == 1)
    
    let user = users.first!
    #expect(user.firstName == "Cruise")
    #expect(user.lastName == "Tom")
    #expect(user.avatarData == nil)
    #expect(user.bio == nil)
    #expect(user.gender == Gender.female.rawValue)
    #expect(user.birthday == DateComponents(calendar: .current, year: 2025, month: 12, day: 21).date!)
    
    initUser.firstName = "Keven"
    initUser.bio = "Fake it till make it!"
    initUser.gender = nil
    try context.save()
    
    // test after
    let fetchedUsers = try context.fetch(FetchDescriptor<User>())
    #expect(fetchedUsers.count == 1)
    
    let fetchedUser = fetchedUsers.first!
    #expect(fetchedUser.firstName == "Keven")
    #expect(fetchedUser.bio == "Fake it till make it!")
    #expect(fetchedUser.gender == nil)
  }
}
