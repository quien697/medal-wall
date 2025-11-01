//
//  PreviewContainer.swift
//  MedalWall
//
//  Created by Quien on 2025-10-31.
//

import Foundation
import SwiftData

@MainActor
struct PreviewContainer {
  static let shared: ModelContainer = {
    let schema = Schema([
      User.self,
      Race.self,
      RaceCategory.self,
      Medal.self
    ])
    let configuration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: schema, configurations: [configuration])
    
    let context = ModelContext(container)
    if let first = try? context.fetch(FetchDescriptor<Race>()).first {
      return container
    }
    
    let user = DefaultUsers.demo
    context.insert(user)
    
    let races = DefaultRaces.all()
    races.forEach { context.insert($0) }
    
    let medals = DefaultMedals.all(for: user, races: races)
    medals.forEach { context.insert($0) }
    
    try? context.save()
    
    return container
  }()
}
