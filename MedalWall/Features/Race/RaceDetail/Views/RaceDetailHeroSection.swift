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
  let place: String
  let url: String?

  var body: some View {
    HStack(alignment: .top, spacing: 16) {
      PhotoImage(
        urlString: photoUrl,
        as: .raceHero
      )

      VStack(alignment: .leading, spacing: 8) {
        Text(name)
          .font(.TypeScale.title2)
          .foregroundStyle(Color.Text.primary)

        Label(place, systemImage: "mappin.and.ellipse")
          .font(.TypeScale.caption)
          .foregroundStyle(Color.Text.secondary)

        if let url = url, let urlObj = URL(string: url) {
          Link(destination: urlObj) {
            Label(url, systemImage: "link")
              .font(.TypeScale.caption)
              .foregroundStyle(Color.Text.secondary)
              .underline(true, color: Color.Text.secondary)
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .leading)
    }
    .padding(.horizontal, 16)
  }
}

#Preview {
  let race = Race.sampleData.first!

  ScrollView {
    RaceDetailHeroSection(
      photoUrl: race.photoUrl,
      name: race.name,
      place: race.place.formatted,
      url: race.websiteUrl
    )
  }
}
