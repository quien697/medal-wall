//
//  PreviewContainer.swift
//  MedalWall
//
//  Created by Quien on 2025-10-31.
//

import SwiftUI
import SwiftData

struct SampleData: PreviewModifier {
  
  static func makeSharedContext() throws -> ModelContainer {
    let schema = Schema([
      User.self,
      Race.self,
      RaceEdition.self,
      RaceCategory.self,
      Medal.self,
      EventPhoto.self
    ])
    let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
    let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
    let context = ModelContext(container)
    context.insert(User.defaultUser)
    Race.sampleData.forEach { context.insert($0) }
    Medal.sampleData.forEach { context.insert($0) }
    try context.save()
    
    return container
  }
  
  func body(content: Content, context: ModelContainer) -> some View {
    content
      .modelContainer(context)
  }
}

extension PreviewTrait where T == Preview.ViewTraits {
  @MainActor static var sampleData: Self = .modifier(SampleData())
}
