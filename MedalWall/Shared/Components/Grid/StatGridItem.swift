//
//  StatGridItem.swift
//  MedalWall
//
//  Created by Quien on 2026-03-05.
//

import SwiftUI

struct StatGridItem: View {
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
    .surfaceStyle()
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
      StatGridItem(title: "32", subTitle: "Races")
      
      StatGridItem(title: "12", subTitle: "Medals", titleColor: Color.Badge.Gold.primary)
      
      StatGridItem(title: "847km", subTitle: "Total")
      
      StatGridItem(title: "12", subTitle: "Finisher")
      
      StatGridItem(title: "9:99:99", subTitle: "Best Full", titleColor: Color.Badge.Gold.primary)
      
      StatGridItem(title: "2:00:19", subTitle: "Best Half")
    }
  }
  .padding()
  .frame(maxWidth: .infinity)
  .background(Color.Card.Background.tertiary)
}
