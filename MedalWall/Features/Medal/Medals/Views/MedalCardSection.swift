//
//  MedalCardSection.swift
//  MedalWall
//
//  Created by Quien on 2025-12-19.
//

import SwiftUI

struct MedalCardSection: View {
  let medal: Medal
  
  var body: some View {
    VStack {
      MedalImage(photo: medal.cropPhoto == nil ? medal.photo : medal.cropPhoto)
      
      VStack(alignment: .leading) {
        Text(medal.raceDistanceCategory.description)
          .font(.caption2)
          .fontWeight(.bold)
          .foregroundStyle(Color.Text.tertiary)
        
        Text(medal.title)
          .font(.headline)
          .foregroundStyle(Color.Text.primary)
//          .lineLimit(1)
        
        Text("05:11:39")
          .font(.subheadline)
          .fontWeight(.heavy)
          .foregroundStyle(Color.Badge.Gold.primary)
        
        Text(medal.date.formatted(date: .abbreviated, time: .omitted))
          .font(.caption)
          .foregroundStyle(.secondary)
          .truncationMode(.tail)
      } // VStack
    } // VStack
    .surfaceStyle()
  }
}

#Preview {
  MedalCardSection(medal: Medal.sampleData[1])
    .frame(width: 160)
}
