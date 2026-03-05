//
//  StatGrid.swift
//  MedalWall
//
//  Created by Quien on 2026-03-05.
//

import SwiftUI

struct StatGrid: View {
  private let padding: CGFloat = 15
  let title: String
  let subTitle: String
  let titleColor: Color?
  
  init(
    title: String,
    subTitle: String,
    titleColor: Color? = nil
  ) {
    self.title = title
    self.subTitle = subTitle
    self.titleColor = titleColor
  }
  
  var body: some View {
    VStack {
      Spacer()
      
      Text(title)
        .font(.largeTitle)
        .fontWeight(.bold)
        .foregroundStyle(titleColor ?? .black)
        .lineLimit(1)
        .minimumScaleFactor(0.5)
      
      Text(subTitle)
        .font(.subheadline)
        .foregroundStyle(Color.Text.tertiary)
        .lineLimit(1)
      
      Spacer()
    }
    .frame(maxWidth: .infinity)
    .modifier(SurfaceStyle(
      background: Color.Card.Background.primary,
      paddingV: padding,
      paddingH: padding
    ))
  }
}

#Preview {
  VStack {
    let columns = [
      GridItem(.flexible(minimum: 80), spacing: 15),
      GridItem(.flexible(minimum: 80), spacing: 15),
      GridItem(.flexible(minimum: 80), spacing: 15),
    ]
    LazyVGrid(columns: columns, spacing: 20) {
      StatGrid(title: "32", subTitle: "Races")
      
      StatGrid(title: "12", subTitle: "Medals", titleColor: Color.Badge.Gold.primary)
      
      StatGrid(title: "847km", subTitle: "Total")
      
      StatGrid(title: "12", subTitle: "Finisher")
      
      StatGrid(title: "9:99:99", subTitle: "Best Full", titleColor: Color.Badge.Gold.primary)
      
      StatGrid(title: "2:00:19", subTitle: "Best Half")
    }
  }
  .padding()
  .frame(maxWidth: .infinity)
  .background(Color.Card.Background.tertiary)
}
