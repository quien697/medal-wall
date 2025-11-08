//
//  CardSectionView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-07.
//

import SwiftUI

struct CardSection<Content: View>: View {
  private let title: String?
  private let alignment: HorizontalAlignment
  private let spacing: CGFloat?
  private let content: Content
  
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
