//
//  PageSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-05.
//

import SwiftUI

/// A page-level section for scrolling layouts: an optionally titled block of content
/// with the standard page padding, for use inside a `ScrollView` where SwiftUI's own
/// `Section` (a `List` / `Form` construct) does not apply.
struct PageSection<Content: View>: View {
  private let title: LocalizedStringKey?
  private let content: Content

  /// Creates a page section.
  /// - Parameters:
  ///   - title: The section heading, or `nil` for an untitled section.
  ///   - content: The content laid out below the heading.
  init(
    title: LocalizedStringKey? = nil,
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
  PageSection(title: "Achievements") {
    VStack {
      Text("123")
    }
  }

  PageSection {
    VStack {
      Text("123")
    }
  }
}
