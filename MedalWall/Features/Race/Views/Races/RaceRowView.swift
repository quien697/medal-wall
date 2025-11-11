//
//  RaceRowView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI
import _SwiftData_SwiftUI

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
  @Previewable @Query(sort: \Race.date) var races: [Race]
  
  RaceRowView(race: races.first!)
}
