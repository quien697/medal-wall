//
//  CardSectionView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-07.
//

import SwiftUI

struct CardSection<Content: View>: View {
  let title: String?
  let alignment: HorizontalAlignment
  let spacing: CGFloat?
  let content: Content
  
  init(
    title: String? = nil,
    alignment: HorizontalAlignment = .center,
    spacing: CGFloat? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()
  }
  
  var body: some View {
    VStack(alignment: alignment, spacing: spacing) {
      if let title = title {
        HStack {
          Text(title)
            .modifier(TextStyleModifier.Card.title)
          
          Spacer()
        }
      }
      
      content
    }
    .cardStyle()
  }
}
