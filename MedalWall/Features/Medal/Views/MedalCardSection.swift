//
//  MedalCardSection.swift
//  MedalWall
//
//  Created by Quien on 2025-12-19.
//

import SwiftUI

struct MedalCardSection: View {
  let medal: Medal
  let spacing: CGFloat
  let size: CGFloat
  
  var body: some View {
    let category = RaceDistanceCategory(value: medal.raceCategory.distance)
    
    CardSection(padding: spacing, margin: 0) {
      MedalBadge(
        photo: medal.photo,
        color: category.color
      )
      
      VStack(alignment: .leading, spacing: spacing) {
        Text(medal.title)
          .font(.headline)
          .lineLimit(2)
          .frame(height: 44, alignment: .topLeading)
        
        HStack {
          Text(medal.date.formatted(date: .abbreviated, time: .omitted))
            .font(.caption)
            .foregroundStyle(.secondary)
            .truncationMode(.tail)
          
          Spacer()
          
          Text(category.description)
            .font(.caption2)
            .bold()
        }
      } // VStack
      .padding(.horizontal, spacing * 0.5)
      .padding(.bottom, spacing)
    } // CardSection
  }
}

#Preview {
  MedalCardSection(medal: Medal.sampleData[1], spacing: 10, size: 160)
    .frame(width: 160)
}
