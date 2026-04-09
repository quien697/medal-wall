//
//  StatCard.swift
//  MedalWall
//
//  Created by Quien on 2026-04-09.
//

import SwiftUI

struct StatCard: View {
  let title: String
  let subTitle: String
  let titleColor: Color
  let width: CGFloat
  let height: CGFloat
  let vPadding: CGFloat
  let hPadding: CGFloat
  
  init(
    title: String,
    subTitle: String,
    titleColor: Color? = nil,
    width: CGFloat? = nil,
    height: CGFloat? = nil,
    vPadding: CGFloat? = nil,
    hPadding: CGFloat? = nil
  ) {
    self.title = title
    self.subTitle = subTitle
    self.titleColor = titleColor ?? Color.Text.primary
    self.width = width ?? .nan
    self.height = height ?? .nan
    self.vPadding = vPadding ?? 16
    self.hPadding = hPadding ?? 16
  }
  
  var body: some View {
    VStack {
      Text(title)
        .font(.largeTitle)
        .fontWeight(.heavy)
        .foregroundStyle(titleColor)
      
      Text(subTitle)
        .font(.subheadline)
        .foregroundStyle(Color.Text.tertiary)
        .lineLimit(1)
    }
    .frame(maxWidth: .infinity)
    .surfaceStyle(
      vPadding: vPadding,
      hPadding: hPadding
    )
  }
}

#Preview {
  HStack(spacing: 16) {
    StatCard(
      title: "32",
      subTitle: "Races",
      width: 80,
      height: 60,
      vPadding: 10
    )
    
    StatCard(
      title: "12",
      subTitle: "Total",
      width: 80,
      vPadding: 0
    )
  }
  .background(Color.Background.primary)
}
