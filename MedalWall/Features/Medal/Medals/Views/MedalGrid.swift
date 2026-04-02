//
//  MedalGrid.swift
//  MedalWall
//
//  Created by Quien on 2026-04-02.
//

import SwiftUI
import SwiftData

struct MedalGrid: View {
  private let size: CGFloat = ImageType.medal.size.width
  private let spacing: CGFloat = 10
  
  @Query private var medals: [Medal]
  
  var body: some View {
    Group {
      if medals.isEmpty {
        ContentUnavailableView(
          "No Medals",
          systemImage: "tray",
          description: Text("Tap the + button to add your first medal!")
        )
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
                MedalCardSection(medal: medal)
              }
              .buttonStyle(.plain)
            }
          }
          .padding(spacing)
        } // ScrollView
      }
    } // Group
  }
}

#Preview {
  MedalGrid()
}
