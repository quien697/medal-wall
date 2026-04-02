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
  }
}

#Preview {
  MedalGrid()
}
