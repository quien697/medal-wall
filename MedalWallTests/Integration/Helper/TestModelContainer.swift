//
//  TestModelContainer.swift
//  MedalWall
//
//  Created by Quien on 2025-11-18.
//

import SwiftData

enum TestModelContainer {
  
  static func make(with schema: Schema) throws -> ModelContainer {
    let config = ModelConfiguration(
      schema: schema,
      isStoredInMemoryOnly: true
    )
    
    return try ModelContainer(
      for: schema,
      configurations: [config]
    )
  }
}

extension TestModelContainer {
  static func makeContext(with schema: Schema) throws -> ModelContext {
    let container = try make(with: schema)
    return ModelContext(container)
  }
}
