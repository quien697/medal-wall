//
//  UserRepositoryIntegrationTests.swift
//  MedalWall
//
//  Created by Quien on 2025-12-08.
//

import Testing
import Foundation
import UIKit
import SwiftData
@testable import MedalWall

struct UserRepositoryIntegrationTests {
  
  @Test("Insert a user")
  func testInsertUser() throws {
    let schema = Schema([User.self])
    let context = try TestModelContainer.makeContext(with: schema)
    
    // test before
    let users = try context.fetch(FetchDescriptor<User>())
    #expect(users.count == 0)
    
    let user = User(
      name: .init(firstName: "Michael", lastName: "Jordan"),
      gender: .male,
    )
    
    let repo = UserRepository(context: context)
    
    try repo.insertUser(user)
    
    // test after
    let fetchedUsers = try context.fetch(FetchDescriptor<User>())
    #expect(fetchedUsers.count == 1)
    
    let fetchedUser = fetchedUsers.first!
    #expect(fetchedUser.firstName == "Michael")
    #expect(fetchedUser.lastName == "Jordan")
    #expect(fetchedUser.gender == Gender.male.rawValue)
  }
}
