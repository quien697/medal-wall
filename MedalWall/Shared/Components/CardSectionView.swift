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
  private let paddingH: CGFloat
  private let paddingV: CGFloat
  private let marginH: CGFloat
  private let marginV: CGFloat
  private let content: Content

  init(
    title: String? = nil,
    alignment: HorizontalAlignment = .center,
    spacing: CGFloat? = nil,
    padding: CGFloat? = nil,
    margin: CGFloat? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.alignment = alignment
    self.spacing = spacing
    self.paddingH = padding ?? 20
    self.paddingV = padding ?? 20
    self.marginH = margin ?? 10
    self.marginV = margin ?? 5
    self.content = content()
  }

  init(
    title: String? = nil,
    alignment: HorizontalAlignment = .center,
    spacing: CGFloat? = nil,
    paddingH: CGFloat? = nil,
    paddingV: CGFloat? = nil,
    marginH: CGFloat? = nil,
    marginV: CGFloat? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.alignment = alignment
    self.spacing = spacing
    self.paddingH = paddingH ?? 20
    self.paddingV = paddingV ?? 20
    self.marginH = marginH ?? 10
    self.marginV = marginV ?? 5
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
    .cardStyle(
      paddingH: paddingH,
      paddingV: paddingV,
      marginH: marginH,
      marginV: marginV
    )
  }
}
