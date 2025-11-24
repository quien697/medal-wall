//
//  DefaultDataSeederTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-18.
//

import Testing
import SwiftData
@testable import MedalWall

struct DefaultDataSeederTests {
  
  @Test("Seeder inserts all default data")
  func testInsertsDefaultData() throws {
    let schema = Schema([
      User.self,
      Race.self,
      RaceCategory.self,
      Medal.self,
    ])
    let context = try TestModelContainer.makeContext(with: schema)
    
    try DefaultDataSeeder.seed(in: context)
    
    #expect(try context.fetch(FetchDescriptor<User>()).count == 1)
    #expect(try context.fetch(FetchDescriptor<Race>()).count == 2)
    #expect(try context.fetch(FetchDescriptor<Medal>()).count == 2)
  }
  
  @Test("Seeder does not insert duplicates")
  func testNoInsertDuplicates() throws {
    let schema = Schema([
      User.self,
      Race.self,
      RaceCategory.self,
      Medal.self,
    ])
    let context = try TestModelContainer.makeContext(with: schema)
    
    try DefaultDataSeeder.seed(in: context)
    let firstCounts = (
      try context.fetch(FetchDescriptor<User>()).count,
      try context.fetch(FetchDescriptor<Race>()).count,
      try context.fetch(FetchDescriptor<Medal>()).count
    )
    
    try DefaultDataSeeder.seed(in: context)
    let secondCounts = (
      try context.fetch(FetchDescriptor<User>()).count,
      try context.fetch(FetchDescriptor<Race>()).count,
      try context.fetch(FetchDescriptor<Medal>()).count
    )
    
    #expect(firstCounts == secondCounts)
  }
}
