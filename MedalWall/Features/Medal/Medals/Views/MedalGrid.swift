//
//  MedalGrid.swift
//  MedalWall
//
//  Created by Quien on 2026-04-02.
//

import SwiftUI
import SwiftData

struct MedalGrid: View {
  let columns: [GridItem]
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
                  distance: medal.distance.displayLabel,
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
    columns: [GridItem](repeating: GridItem(.flexible(minimum: 80), spacing: 10), count: 2),
    spacing: 10
  )
}
