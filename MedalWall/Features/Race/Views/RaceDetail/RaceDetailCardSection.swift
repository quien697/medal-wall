//
//  RaceDetailCardSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI

struct RaceDetailCardSection: View {
  let race: Race
  
  var body: some View {
//    let groupedDistances = race.distances.groupedByType()
    
//    CardSection {
//      CardRow(
//        icon: "clock",
//        value: race.date.formatted(date: .abbreviated, time: .omitted)
//      )
//      
//      CardRow(
//        icon: "location.fill",
//        value: race.location.formatted
//      )
//      
//      if race.distances.count != 0 {
//        CardRow(icon: "figure.run") {
//          VStack(alignment: .leading) {
//            
//            ForEach(RaceDistanceType.allCases) { type in
//              if let distances = groupedDistances[type], !distances.isEmpty {
//                Text(type.displayName)
//                
//                HStack {
//                  ForEach(distances) { distance in
//                    Text(distance.category.description)
//                      .font(.subheadline)
//                      .foregroundStyle(.primary)
//                      .padding(.vertical, 7)
//                      .padding(.horizontal)
//                      .background(distance.category.translucentColor)
//                      .clipShape(.rect(cornerRadius: 12))
//                  } // ForEach
//                } // HStack
//              }
//            } // ForEach
//          } // VStack
//        } // CardListItem
//      }
//      
//      if let url = race.url {
//        CardRow(icon: "globe", withBottomLine: false) {
//          Link("Visit Website", destination: URL(string: url)!)
//            .underline(true, color: .blue.opacity(0.8))
//        }
//      }
//    } // CardSection
  }
}

#Preview {
  RaceDetailCardSection(race: Race.sampleData.first!)
}
