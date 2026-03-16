//
//  RaceHeroCardSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI

struct RaceHeroCardSection: View {
  let photo: UIImage?
  let cropPhoto: UIImage?
  let name: String
  let location: String
  let url: String?
  
  var body: some View {
    HStack {
      ZStack(alignment: .leading) {
        if let uiImage = cropPhoto ?? photo {
          Image(uiImage: uiImage)
            .raceHero()
          
        } else {
          Image(systemName: "photo.fill")
            .raceHero()
        }
      } // ZStack
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
      
      VStack(alignment: .leading, spacing: 6) {
        Text(name)
          .font(.title2)
          .fontWeight(.bold)
          .foregroundStyle(Color.Text.primary)
        
        Text(location)
          .font(.subheadline)
          .foregroundStyle(Color.Text.tertiary)
        
        if let url = url, let urlObj = URL(string: url) {
          Link(url, destination: urlObj)
            .font(.subheadline)
            .foregroundStyle(Color.Text.secondary)
            .underline(true, color: Color.Text.secondary)
        }
      } // VStack
      .frame(maxWidth: .infinity)
    } // HStack
    .padding(.vertical, 40)
    .padding(.horizontal)
    .frame(maxWidth: .infinity)
    .background(.thinMaterial)
    .overlay(alignment: .bottom) {
      Rectangle()
        .fill(Color.Border.gray)
        .frame(height: 1)
    }
  }
}

#Preview {
  let race = Race.sampleData.first!
  
  RaceHeroCardSection(
    photo: race.photo,
    cropPhoto: race.cropPhoto,
    name: race.name,
    location: race.location.formatted,
    url: race.url
  )
}
