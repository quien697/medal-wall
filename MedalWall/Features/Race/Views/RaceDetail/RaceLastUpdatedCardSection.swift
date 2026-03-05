//
//  RaceLastUpdatedCardSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI

struct RaceLastUpdatedCardSection: View {
  let race: Race
  
  var body: some View {
//    CardSection(alignment: .leading) {
//      Text(race.updateTime.formatted(date: .abbreviated, time: .standard))
//        .foregroundStyle(.secondary)
//    }
  }
}

#Preview {
  RaceLastUpdatedCardSection(race: Race.sampleData.first!)
}
