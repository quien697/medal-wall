//
//  MedalsView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

struct MedalsView: View {
  @Environment(\.modelContext) private var modelContext
  private let spacing: CGFloat = 10
  private let size: CGFloat = 160
  
  @Query(sort: [SortDescriptor(\Medal.date, order: .reverse)], animation: .default)
  private var medals: [Medal]
  
  var body: some View {
    Group {
      if medals.isEmpty {
        ZStack {
          ContentUnavailableView {
            Label("No Medals", systemImage: "medal")
          } description: {
            Text("You haven't added any medals yet.")
          }
        }
      } else {
        let columns = Array(
          repeating: GridItem(.flexible(minimum: size + 20), spacing: spacing),
          count: 2
        )
        
        ScrollView {
          LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(medals, id: \.id) { medal in
              MedalCard(medal: medal, spacing: spacing, size: size)
            }
          }
          .padding(spacing)
        } // ScrollView
      }
    } // Group
    .navigationTitle("Your Rewards")
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Add Race", systemImage: "plus") {
          
        }
      }
      
      ToolbarItem(placement: .topBarTrailing) {
        Button("Filter", systemImage: "ellipsis") {
          
        }
      }
    }
  }
}

#Preview(traits: .sampleData) {
  MedalsView()
}
