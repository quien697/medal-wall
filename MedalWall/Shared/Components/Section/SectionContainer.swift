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
          .font(.headline)
          .fontWeight(.heavy)
          .fontDesign(.rounded)
          .textCase(.uppercase)
          .foregroundStyle(Color.Text.tertiary)
      }
      
      content
    }
    .padding(.horizontal)
    .padding(.vertical, 10)
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
        StatGrid(title: "32", subTitle: "Races")
        
        StatGrid(title: "12", subTitle: "Medals", titleColor: Color.Badge.Gold.primary)
        
        StatGrid(title: "847km", subTitle: "Total")
        
        StatGrid(title: "12", subTitle: "Finisher")
        
        StatGrid(title: "9:99:99", subTitle: "Best Full", titleColor: Color.Badge.Gold.primary)
        
        StatGrid(title: "9:99:99", subTitle: "Best Half")
      }
    }
  }
}
