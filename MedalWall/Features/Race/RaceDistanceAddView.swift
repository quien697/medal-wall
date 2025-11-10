//
//  RaceDistanceAddView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-10.
//

import SwiftUI
import SwiftData

struct RaceDistanceAddView: View {
  @Binding var distance: RaceDistance
  
  var body: some View {
    RaceDistanceEditView(distance: $distance)
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  
  NavigationStack{
    RaceDistanceAddView(distance: .constant(races[0].distances[0]))
  }
}
