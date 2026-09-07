//
//  MedalDetailNoteSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-07.
//

import SwiftUI

struct MedalDetailNoteSection: View {
  let note: String

  var body: some View {
    PageSection(title: "Notes") {
      Text(note)
        .font(.body)
        .foregroundStyle(Color.Text.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .lineLimit(3...)
        .surfaceStyle()
    }  // PageSection
  }
}

#Preview {
  ScrollView {
    MedalDetailNoteSection(
      note:
        "First half marathon! Legs felt strong until km 18. Loved the course"
        + " along the city landmarks. Will be back!"
    )

    MedalDetailNoteSection(note: "First half marathon!")
  }
}
