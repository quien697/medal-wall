//
//  RaceDetailHeroSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI

struct RaceDetailHeroSection: View {
  let photo: UIImage?
  let name: String
  let location: String
  let url: String?
  
  var body: some View {
    DetailHeroSection {
      ZStack(alignment: .leading) {
        if let photo {
          Image(uiImage: photo)
            .styled(as: ImageType.raceHero)
          
        } else {
          Image(systemName: "photo.fill")
            .placeholderStyled(as: ImageType.raceHero)
        }
      } // ZStack
      .clipShape(RoundedRectangle(cornerRadius: 12))
      .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
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
      photo: race.cropPhoto ?? race.photo,
      name: race.name,
      location: race.location.formatted,
      url: race.url
    )
  }
}
