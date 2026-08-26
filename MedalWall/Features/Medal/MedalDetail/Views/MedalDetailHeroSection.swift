//
//  MedalDetailHeroSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-06.
//

import SwiftUI

struct MedalDetailHeroSection: View {
  let photoUrl: String?
  let name: String
  let raceDistance: String
  let raceDistanceType: String
  let place: String
  let date: String
  let bib: String

  var body: some View {
    DetailHeroSection {
      MedalImage(urlString: photoUrl)
    } infoContent: {
      HStack(spacing: 6) {
        Text(raceDistance)
          .tagStyle(.neutral)

        Text(raceDistanceType)
          .tagStyle(.neutral)
      }  // HStack

      Text(name)
        .font(.title3)
        .fontWeight(.bold)
        .foregroundStyle(Color.Text.primary)
        .fixedSize(horizontal: false, vertical: true)
        .frame(maxWidth: .infinity, alignment: .leading)

      VStack(alignment: .leading, spacing: 8) {
        Label(place, systemImage: "mappin.and.ellipse")
        Label(date, systemImage: "calendar")
        Label("Bib \(bib)", systemImage: "number")
      }  // VStack
      .font(.caption)
      .foregroundStyle(Color.Text.secondary)
    }  // DetailHeroSection
  }
}

#Preview {
  let medal = Medal.sampleData.first!

  MedalDetailHeroSection(
    photoUrl: medal.photoUrl,
    name: medal.name,
    raceDistance: MedalDetailViewModel.heroDistanceText(
      for: medal.distance.category,
      in: DistanceUnit.resolved()
    ),
    raceDistanceType: medal.distance.type.displayName,
    place: medal.place.formatted,
    date: medal.date.formattedMonthDayYear(),
    bib: medal.bibNumber
  )
}
