//
//  SectionContainer.swift
//  MedalWall
//
//  Created by Quien on 2026-03-05.
//

import SwiftUI

struct SectionContainer<Content: View>: View {
  private let title: String?
  private let content: Content
  
  init(
    title: String? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.content = content()
  }
  
  var body: some View {
    VStack(alignment: .leading) {
      if let title {
        Text(title)
          .sectionTitleStyle()
      }
      
      content
    }
    .padding(.horizontal, 16)
    .padding(.vertical, 8)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview {
  SectionContainer(title: "Achievements") {
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
        
        StatGridItem(title: "9:99:99", subTitle: "Best Half")
      }
    }
  }
}
