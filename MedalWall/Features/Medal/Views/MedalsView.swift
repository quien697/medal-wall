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
  @State private var isShowMedalAddView = false
  
  private let spacing: CGFloat = 10
  private let size: CGFloat = ImageType.medal.size.width
  
  @Query(sort: [SortDescriptor(\Medal.date, order: .reverse)], animation: .default)
  private var medals: [Medal]
  
  @Query private var users: [User]
  private var user: User? { users.first }
  
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
              NavigationLink {
                MedalDetailView(medal: medal)
              } label: {
                MedalCardSection(medal: medal, spacing: spacing)
              }
              .buttonStyle(.plain)
            }
          }
          .padding(spacing)
        } // ScrollView
      }
    } // Group
    .navigationTitle("Your Rewards")
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Add Medal", systemImage: "plus") {
          isShowMedalAddView = true
        }
      }
    }
    .sheet(isPresented: $isShowMedalAddView) {
      if let user {
        NavigationStack {
          MedalAddView(user: user)
        }
      }
    }
  }
}

#Preview(traits: .sampleData) {
  MedalsView()
}
