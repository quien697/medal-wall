//
//  MedalDetailStatsGridItem.swift
//  MedalWall
//
//  Created by Quien on 2026-04-07.
//

import SwiftUI

struct MedalDetailStatsGridItem: View {
  let title: String
  let headline: String
  let subHeadLine: String?
  let headLineColor: Color?
  
  // MARK: - Init
  init(
    title: String,
    headline: String,
    subHeadLine: String? = nil,
    headLineColor: Color? = nil
  ) {
    self.title = title
    self.headline = headline
    self.subHeadLine = subHeadLine
    self.headLineColor = headLineColor
  }
  
  // MARK: - Body
  var body: some View {
    VStack(alignment: .leading, spacing: 5) {
      Text(title)
        .font(.caption)
        .fontWeight(.bold)
        .textCase(.uppercase)
        .foregroundStyle(Color.Text.secondary)
      
      Text(headline)
        .font(.title)
        .fontWeight(.bold)
        .foregroundStyle(headLineColor ?? Color.Text.primary)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
      
      if let subHeadLine {
        Text(subHeadLine)
          .font(.caption)
          .foregroundStyle(Color.Text.secondary)
          .lineLimit(1)
      }
    } // VStack
    .frame(maxWidth: .infinity, alignment: .leading)
    .surfaceStyle()
  }
}

#Preview {
  let columns = [
    GridItem(.flexible(minimum: 80), spacing: 10),
    GridItem(.flexible(minimum: 80), spacing: 10),
  ]
  
  LazyVGrid(columns: columns, spacing: 10) {
    MedalDetailStatsGridItem(
      title: "Finish Time",
      headline: "5:10:10",
      headLineColor: Color.Gold.primary
    )
    
    MedalDetailStatsGridItem(
      title: "AVG Pace",
      headline: "5.31 /km"
    )
    
    MedalDetailStatsGridItem(
      title: "Overall",
      headline: "4000",
      subHeadLine: "of 7000",
      headLineColor: Color.Gold.primary
    )
    
    MedalDetailStatsGridItem(
      title: "Division",
      headline: "30",
      subHeadLine: "of 500"
    )
    
    MedalDetailStatsGridItem(
      title: "Division Group",
      headline: "M30-40",
      subHeadLine: ""
    )
    
    MedalDetailStatsGridItem(
      title: "Gender",
      headline: "700",
      subHeadLine: "of 1000"
    )
  }
  .padding()
  .background(Color.Card.Background.tertiary)
}
