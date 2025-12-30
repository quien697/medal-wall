//
//  MedalCard.swift
//  MedalWall
//
//  Created by Quien on 2025-12-19.
//

import SwiftUI

struct MedalCard: View {
  let medal: Medal
  let spacing: CGFloat
  let size: CGFloat
  
  var body: some View {
    let category = RaceDistanceCategory(value: medal.raceCategory.distance)
    
    CardSection(padding: spacing, margin: 0) {
      MedalBadgeView(
        photo: medal.photo,
        color: category.color
      )
      
      VStack(alignment: .leading, spacing: 10) {
        Text(medal.title)
          .font(.headline)
          .lineLimit(2)
          .frame(height: 44, alignment: .topLeading)
        
        HStack(spacing: 8) {
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
    } // CardSection
  }
}

#Preview(traits: .sampleData) {
  MedalCard(medal: Medal.sampleData[1], spacing: 10, size: 160)
    .frame(width: 180)
}
