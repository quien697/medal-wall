//
//  MedalDetailTagsSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-07.
//

import SwiftUI

struct MedalDetailTagsSection: View {
  let tags: [String]

  var body: some View {
    PageSection(title: "Tags") {
      FlowLayout(spacing: 6) {
        ForEach(tags, id: \.self) { tag in
          Text(tag)
            .tagStyle(.neutralOnPage)
        }  // ForEach
      }  // FlowLayout
    }  // PageSection
  }
}

#Preview {
  MedalDetailTagsSection(tags: ["marathon", "taipei", "2026", "台北"])
}
