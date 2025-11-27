//
//  RaceHeroCardSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI

struct RaceHeroCardSection: View {
  let race: Race
  
  var body: some View {
    CardSection(spacing: 12) {
      ZStack {
        if let uiImage = race.photo {
          Image(uiImage: uiImage)
            .raceHero()
        } else {
          Image(systemName: "photo.fill")
            .raceHero()
        }
      } // ZStack
      .frame(maxWidth: .infinity)
      .clipShape(RoundedRectangle(cornerRadius: 12))
      
      VStack {
        Text(race.name)
          .font(.headline)
          .multilineTextAlignment(.center)
        
        Text(race.location.formatted)
          .font(.subheadline)
      } // VStack
      .padding(.horizontal, 12)
      .padding(.top, 12)
    } // CardSection
  }
}

#Preview {
  RaceHeroCardSection(race: Race.sampleData.first!)
}
