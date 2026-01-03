//
//  CardSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-07.
//

import SwiftUI

struct CardSection<Content: View>: View {
  private let radius: CGFloat = 20
  
  private let title: String?
  private let alignment: Alignment
  private let spacing: CGFloat?
  private let padding: CGFloat
  private let margin: CGFloat
  private let content: Content
  
  private var horizontalAlignment: HorizontalAlignment {
    if alignment == .leading { return .leading }
    if alignment == .trailing { return .trailing }
    return .center
  }
  
  init(
    title: String? = nil,
    alignment: Alignment = .center,
    spacing: CGFloat? = nil,
    padding: CGFloat = 20,
    margin: CGFloat = 10,
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.alignment = alignment
    self.spacing = spacing
    self.padding = padding
    self.margin = margin
    self.content = content()
  }
  
  var body: some View {
    VStack {
      // Header
      if let title = title {
        VStack {
          Text(title)
            .font(.headline)
            .foregroundColor(.primary)
        }
        .padding(padding * 0.8)
        .frame(maxWidth: .infinity, alignment: alignment)
        .background(.thinMaterial)
      }
      
      // Content body
      VStack(alignment: horizontalAlignment, spacing: spacing) {
        content
      }
      .padding(padding * 0.8)
      .frame(maxWidth: .infinity, alignment: alignment)
      
    }
    .background(.background)
    .clipShape(.rect(cornerRadius: radius))
    .shadow(color: .black.opacity(0.2), radius: 4)
    .padding(margin)
  }
}

#Preview(traits: .sampleData) {
  ScrollView {
    CardSection(title: "Note", spacing: 8) {
      Image(systemName: "star.fill")
      Text("Title")
    }
    
    CardSection(title: "Note", alignment: .leading) {
      Text("Some content")
    }
    
    CardSection(title: "Note", alignment: .leading) {
      Text("Some content some content Some content Some content Some content Some content Some content Some content Some content Some content")
    }
    
    CardSection(title: "Note", alignment: .leading) {
      Text("Some content")

      Text("Some content some content Some content Some content Some content Some content Some content Some content Some content Some content")
    }
    
    CardSection(title: "Details", alignment: .leading, spacing: 8) {
      CardRow(icon: "calendar", value: "Jan 1, 2026")
      CardRow(icon: "bolt", value: "42km")
    }
    
    CardSection(title: "Details", alignment: .leading, spacing: 8) {
      CardRow(label: "Calendar", value: "Jan 1, 2026")
      CardRow(label: "Distance", value: "42km")
    }
  }
}
