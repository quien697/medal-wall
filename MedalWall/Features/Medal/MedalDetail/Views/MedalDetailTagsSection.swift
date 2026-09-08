//
//  MedalDetailTagsSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-07.
//

import SwiftUI

/// The hashtags a user filed the medal under.
///
/// Capsules, not rect tags: shape is what separates a label that *names* something from a
/// fact the user cannot change, and a hashtag is the former.
struct MedalDetailTagsSection: View {
  let tags: [String]

  var body: some View {
    PageSection(title: "Tags") {
      FlowLayout(spacing: 6) {
        ForEach(tags, id: \.self) { tag in
          Text(tag)
            .chipStyle(.neutral)
        }  // ForEach
      }  // FlowLayout
    }  // PageSection
  }
}

#Preview {
  MedalDetailTagsSection(tags: ["marathon", "taipei", "2026", "台北"])
}
