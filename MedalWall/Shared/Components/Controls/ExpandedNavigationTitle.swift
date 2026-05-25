//
//  ExpandedNavigationTitle.swift
//  MedalWall
//
//  Created by Quien on 2026-04-09.
//

import SwiftUI

/// A large title in an expanded font.
struct ExpandedNavigationTitle: View {
  var title: LocalizedStringKey

  var body: some View {
    HStack {
      Text(title)
        .font(.system(size: 34, weight: .bold))
        .fixedSize()

      Spacer()
    }
  }
}

#Preview {
  NavigationStack {
    Text("Hello world")
      .toolbar {
        ToolbarItem(placement: .largeTitle) {
          ExpandedNavigationTitle(title: "Title")
        }
      }
      .toolbarTitleDisplayMode(.inlineLarge)
      .navigationTitle("Title")
  }
}
