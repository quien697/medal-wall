//
//  PageSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-05.
//

import SwiftUI

/// A page-level section for scrolling layouts: an optionally titled block of content
/// carrying the standard page padding.
///
/// Use it inside a `ScrollView`, where SwiftUI's own `Section` — a `List` / `Form`
/// construct — does not apply.
///
/// `spacing` only spaces the heading from the content; siblings inside `content` are
/// laid out by whatever `content` itself uses. Wrap `content` in a `VStack` (or similar)
/// when the section needs to space its own children.
///
/// ```swift
/// ScrollView {
///   PageSection(title: "The result") {
///     MedalDetailResultItem(label: "Finish", value: "03:30:24", suffix: nil)
///   }
///
///   PageSection(title: "The day") {
///     Text(note).surfaceStyle()
///   }
/// }
/// ```
///
struct PageSection<Content: View>: View {
  private let title: LocalizedStringKey?
  private let alignment: HorizontalAlignment
  private let spacing: CGFloat?
  private let content: Content

  /// Creates a page section.
  /// - Parameters:
  ///   - title: The section heading, or `nil` for an untitled section. A
  ///     `LocalizedStringKey`, so a literal is translated and a runtime-built `String`
  ///     is not.
  ///   - alignment: How the heading and the content line up. Applies to both, so
  ///     `.center` centres the heading as well.
  ///   - spacing: The gap between the heading and the content. Siblings inside the
  ///     content keep whatever spacing `content` itself provides.
  ///   - content: The content laid out below the heading, written without page margins —
  ///     the section supplies them.
  init(
    title: LocalizedStringKey? = nil,
    alignment: HorizontalAlignment = .leading,
    spacing: CGFloat? = .Space.gutter,
    @ViewBuilder content: () -> Content
  ) {
    self.title = title
    self.alignment = alignment
    self.spacing = spacing
    self.content = content()
  }

  var body: some View {
    VStack(alignment: alignment, spacing: spacing) {
      if let title {
        Text(title)
          .sectionTitleStyle()
      }

      content
    }
    .padding(.horizontal, .Space.gutter)
    .padding(.vertical, .Space.stack)
    .frame(maxWidth: .infinity, alignment: .leading)
  }
}

#Preview("Titled") {
  PageSection(title: "Achievements") {
    Text("A section states what it holds, then holds it.")
      .font(.TypeScale.body)
      .foregroundStyle(Color.Text.primary)
  }  // PageSection
  .background(Color.Background.primary)
}

#Preview("Untitled") {
  PageSection {
    Text("Without a heading the content keeps the same page padding.")
      .font(.TypeScale.body)
      .foregroundStyle(Color.Text.primary)
  }  // PageSection
  .background(Color.Background.primary)
}

#Preview("Centred") {
  PageSection(title: "Centred", alignment: .center) {
    Text("The heading follows the alignment, not just the content.")
      .font(.TypeScale.body)
      .foregroundStyle(Color.Text.primary)
      .multilineTextAlignment(.center)
  }  // PageSection
  .background(Color.Background.primary)
}

#Preview("Custom spacing") {
  PageSection(title: "Spacing", spacing: .Space.row) {
    ForEach(1...3, id: \.self) { index in
      Text("Row \(index)")
        .font(.TypeScale.body)
        .foregroundStyle(Color.Text.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .surfaceStyle()
    }  // ForEach
  }  // PageSection
  .background(Color.Background.primary)
}

#Preview("Stacked in a scroll view") {
  ScrollView {
    PageSection(title: "The result") {
      Text("03:30:24")
        .font(.TypeScale.Numeric.large)
        .foregroundStyle(Color.Text.primary)
    }  // PageSection

    PageSection(title: "The day") {
      Text("The weather was good, not too much up hill and down hill.")
        .font(.TypeScale.body)
        .foregroundStyle(Color.Text.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .surfaceStyle()
    }  // PageSection
  }  // ScrollView
  .background(Color.Background.primary)
}
