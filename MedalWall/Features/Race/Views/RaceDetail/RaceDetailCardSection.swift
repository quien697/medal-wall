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
    let groupedDistances = race.distances.groupedByType()
    
    CardSection(title: "Details") {
      CardListItem(systemName: "clock") {
        Text(race.date.formatted(date: .abbreviated, time: .omitted))
          .modifier(TextStyleModifier.Card.listText)
      }
      
      CardListItem(systemName: "location.fill") {
        Text(race.location.formatted)
          .modifier(TextStyleModifier.Card.listText)
      }
      
      if race.distances.count != 0 {
        CardListItem(systemName: "figure.run",alignment: .top) {
          VStack(alignment: .leading) {
            
            ForEach(RaceDistanceType.allCases) { type in
              if let distances = groupedDistances[type], !distances.isEmpty {
                Text(type.displayName)
                  .modifier(TextStyleModifier.Card.listText)
                
                HStack {
                  ForEach(distances) { distance in
                    Text(distance.category.description)
                      .font(.subheadline)
                      .foregroundStyle(.primary)
                      .padding(.vertical, 7)
                      .padding(.horizontal)
                      .background(distance.category.color)
                      .clipShape(.rect(cornerRadius: 12))
                  } // ForEach
                } // HStack
              }
            } // ForEach
          } // VStack
        } // CardListItem
      }
      
      if let url = race.url {
        CardListItem(systemName: "globe") {
          Link("Visit Website", destination: URL(string: url)!)
            .modifier(TextStyleModifier.Card.listLink)
            .underline(true, color: .blue.opacity(0.8))
        }
      }
    } // CardSection
  }
}

#Preview {
  RaceDetailCardSection(race: Race.sampleData.first!)
}
