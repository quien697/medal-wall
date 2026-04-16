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
      Text("123")
    }
  }
  
  SectionContainer {
    VStack {
      Text("123")
    }
  }
}
