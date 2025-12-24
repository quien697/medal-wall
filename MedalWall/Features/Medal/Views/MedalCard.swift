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
      ZStack {
        Hexagon()
          .fill(
            LinearGradient(
              colors: [
                category.color.opacity(0.8),
                category.color.opacity(0.5)
              ],
              startPoint: .topLeading,
              endPoint: .bottomTrailing
            )
          )
          .stroke(.black.opacity(0.1), lineWidth: 2)
          .frame(width: size, height: size)
        
        if let uiImage = medal.photo {
          Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .frame(width: size * 0.7, height: size * 0.7)
            .clipShape(Circle())
            .shadow(radius: 4)
        } else {
          Image(systemName: "medal.fill")
            .font(.system(size: size * 0.3, weight: .semibold))
            .foregroundColor(.white)
        }
      } // ZStack
      
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
