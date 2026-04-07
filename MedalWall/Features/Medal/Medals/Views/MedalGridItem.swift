//
//  MedalGridItem.swift
//  MedalWall
//
//  Created by Quien on 2025-12-19.
//

import SwiftUI

struct MedalGridItem: View {
  let photo: UIImage?
  let distance: String
  let title: String
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
        
        Text(title)
          .font(.headline)
          .foregroundStyle(Color.Text.primary)
        
        Text(finishTime)
          .font(.subheadline)
          .fontWeight(.heavy)
          .foregroundStyle(Color.Badge.Gold.primary)
        
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
  
  MedalGridItem(
    photo: medal.cropPhoto ?? medal.photo,
    distance: medal.distance.displayLabel,
    title: medal.name,
    finishTime: medal.finishTime?.formattedHMS ?? "-",
    date: medal.date.formattedMonthDayYear()
  )
  .frame(width: 160)
}
