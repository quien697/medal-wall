//
//  MedalGrid.swift
//  MedalWall
//
//  Created by Quien on 2026-04-02.
//

import SwiftUI
import SwiftData

struct MedalGrid: View {
  let columnCount: Int
  let spacing: CGFloat
  
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
          repeating: GridItem(.flexible(), spacing: spacing),
          count: columnCount
        )
        
//        ScrollView(.horizontal) {
//          HStack(spacing: 10) {
//            StatGridItem(title: "12", subTitle: "Total")
//              .frame(width: 80, height: 80)
//            
//            StatGridItem(title: "5", subTitle: "Full")
//              .frame(width: 80, height: 80)
//            
//            StatGridItem(title: "4", subTitle: "Half")
//              .frame(width: 80, height: 80)
//          }
//          .padding()
//        }
        
        ScrollView {
          LazyVGrid(columns: columns, spacing: spacing) {
            ForEach(medals, id: \.id) { medal in
              NavigationLink {
                MedalDetailView(medal: medal)
              } label: {
                MedalGridItem(
                  photo: medal.cropPhoto ?? medal.photo,
                  distanceCategory: medal.raceDistanceCategory.description,
                  title: medal.name,
                  finishTime: medal.finishTime?.formattedHMS ?? "-",
                  date: medal.date.formattedMonthDayYear()
                )
              }
              .buttonStyle(.plain)
            }
          } // LazyVGrid
          .padding(.horizontal)
        } // ScrollView
      }
    } // Group
  }
}

#Preview {
  MedalGrid(
    columnCount: 2,
    spacing: 10
  )
}
