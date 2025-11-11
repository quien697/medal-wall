//
//  RaceDetailCardSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI
import SwiftData

struct RaceDetailCardSection: View {
  @Environment(\.modelContext) private var modelContext
  let viewModel: RaceDetailViewModel
  
  var body: some View {
    CardSection(title: "Details") {
      CardListItem(systemName: "clock") {
        Text(viewModel.race.date.formatted(date: .abbreviated, time: .omitted))
          .modifier(TextStyleModifier.Card.listText)
      }
      
      CardListItem(systemName: "location.fill") {
        Text(viewModel.race.location.formatted)
          .modifier(TextStyleModifier.Card.listText)
      }
      
      if viewModel.race.distances.count != 0 {
        CardListItem(systemName: "figure.run",alignment: .top) {
          VStack(alignment: .leading) {
            ForEach(viewModel.distancesByType.keys.sorted(), id: \.self) { type in
              Text(type)
                .modifier(TextStyleModifier.Card.listText)
              
              HStack {
                ForEach((viewModel.distancesByType[type] ?? []).sortedByDistance()) { distance in
                  Text(distance.category.description)
                    .font(.subheadline)
                    .foregroundStyle(.primary)
                    .padding(.vertical, 7)
                    .padding(.horizontal)
                    .background(distance.category.color)
                    .clipShape(.rect(cornerRadius: 12))
                } // ForEach
              } // HStack
            } // ForEach
          } // VStack
        } // CardListItem
      }
      
      if let url = viewModel.race.url {
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
  RaceDetailCardSection(
    viewModel: RaceDetailViewModel(race: Race.sampleData.first!))
}
