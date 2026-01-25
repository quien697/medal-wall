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
  
  var body: some View {
    let category = RaceDistanceCategory(value: medal.raceCategory.distance)
    
    CardSection(padding: spacing, margin: 0) {
      MedalBadge(photo: medal.cropPhoto == nil ? medal.photo : medal.cropPhoto)
      
      VStack(alignment: .leading, spacing: spacing) {
        Text(medal.title)
          .font(.headline)
          .lineLimit(1)
        
        HStack {
          Text(medal.date.formatted(date: .abbreviated, time: .omitted))
            .font(.caption)
            .foregroundStyle(.secondary)
            .truncationMode(.tail)
          
          Spacer()
          
          Text(category.description)
            .font(.caption2)
            .bold()
            .padding(.horizontal, 6)
            .padding(.vertical, 4)
            .background(category.translucentColor)
            .clipShape(.rect(cornerRadius: 6) )
            
        } // HStack
      } // VStack
      .padding(.horizontal, spacing * 0.5)
      .padding(.bottom, spacing)
    } // CardSection
  }
}

#Preview {
  MedalCardSection(medal: Medal.sampleData[1], spacing: 10)
    .frame(width: 160)
}
