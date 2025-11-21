//
//  RaceRowView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI

struct RaceRowView: View {
  let race: Race
  
  var body: some View {
    HStack {
      Image(race.photo ?? "")
        .resizable()
        .scaledToFit()
        .frame(width: 60, height: 60)
        .clipShape(.rect(cornerRadius: 10))
      
      VStack(alignment: .leading) {
        Text(race.name)
          .font(.headline)
        
        Text(race.location.formatted)
          .font(.subheadline)
          .foregroundStyle(.secondary)
        
        Text(race.date.formatted(date: .abbreviated, time: .omitted))
          .font(.caption)
      }
    }
  }
}

#Preview(traits: .sampleData) {
  RaceRowView(race: Race.sampleData.first!)
}
