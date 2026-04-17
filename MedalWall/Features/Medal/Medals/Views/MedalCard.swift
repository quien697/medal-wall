//
//  MedalCard.swift
//  MedalWall
//
//  Created by Quien on 2025-12-19.
//

import SwiftUI

struct MedalCard: View {
  let photo: UIImage?
  let distance: String
  let name: String
  let finishTime: String
  let date: String
  
  var body: some View {
    VStack {
      MedalImage(photo: photo)
      
      VStack(alignment: .leading, spacing: 2) {
        Text("\(distance)")
          .font(.caption2)
          .fontWeight(.bold)
          .foregroundStyle(Color.Text.tertiary)
        
        Text(name)
          .font(.headline)
          .foregroundStyle(Color.Text.primary)
          .lineLimit(2)
          .frame(minHeight: 44, alignment: .topLeading)
        
        Text(finishTime)
          .font(.subheadline)
          .fontWeight(.heavy)
          .foregroundStyle(Color.Gold.primary)
        
        Text(date)
          .font(.caption)
          .foregroundStyle(.secondary)
          .truncationMode(.tail)
      } // VStack
      .frame(maxWidth: .infinity, alignment: .leading)
    } // VStack
    .frame(maxWidth: .infinity)
    .surfaceStyle()
  }
}

#Preview {
  let medal = Medal.sampleData[1]
  
  MedalCard(
    photo: medal.cropPhoto ?? medal.photo,
    distance: medal.distance.displayLabel,
    name: medal.name,
    finishTime: medal.finishTime?.formattedHMS ?? "-",
    date: medal.date.formattedMonthDayYear()
  )
  .frame(width: 160)
}
