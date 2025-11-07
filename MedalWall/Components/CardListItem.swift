//
//  CardListItem.swift
//  MedalWall
//
//  Created by Quien on 2025-11-07.
//

import SwiftUI

struct CardListItem<Content: View>: View {
  private let systemName: String?
  private let content: Content

  init(
    systemName: String? = nil,
    @ViewBuilder content: () -> Content
  ) {
    self.systemName = systemName
    self.content = content()
  }

  var body: some View {
    Divider()
    
    HStack {
      if let systemName {
        Image(systemName: systemName)
          .modifier(IconStyleModifier.cardListIcon)
      }
      
      content
    }
    .frame(maxWidth: .infinity, alignment: .leading)
    .padding(.vertical, 6)
  }
}
