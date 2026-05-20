//
//  RaceDetailHeroSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI

struct RaceDetailHeroSection: View {
  let photoUrl: String?
  let name: String
  let location: String
  let url: String?
  
  var body: some View {
    DetailHeroSection {
      RaceImage(
        urlString: photoUrl,
        imageType: .raceHero
      )
    } infoContent: {
      Text(name)
        .font(.title2)
        .fontWeight(.bold)
        .foregroundStyle(Color.Text.primary)
      
      Label(location, systemImage: "mappin.and.ellipse")
        .font(.caption)
        .foregroundStyle(Color.Text.secondary)
      
      if let url = url, let urlObj = URL(string: url) {
        Link(destination: urlObj) {
          Label(url, systemImage: "link")
            .font(.caption)
            .foregroundStyle(Color.Text.secondary)
            .underline(true, color: Color.Text.secondary)
        }
      }
    } // DetailHeroSection
  }
}

#Preview {
  let race = Race.sampleData.first!
  
  ScrollView {
    RaceDetailHeroSection(
      photoUrl: race.photoUrl,
      name: race.name,
      location: race.location.formatted,
      url: race.websiteUrl
    )
  }
}
