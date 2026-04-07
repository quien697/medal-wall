//
//  MedalDetailTagsSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-07.
//

import SwiftUI

struct MedalDetailTagsSection: View {
  var body: some View {
    SectionContainer(title: "Tags") {
      FlowLayout(spacing: 6) {
        Text("marathon")
          .secondaryButtonStyle(
            vPadding: 5,
            hPadding: 10
          )
        
        Text("taipei")
          .secondaryButtonStyle(
            vPadding: 5,
            hPadding: 10
          )
        
        Text("2026")
          .secondaryButtonStyle(
            vPadding: 5,
            hPadding: 10
          )
        
        Text("台北")
          .secondaryButtonStyle(
            vPadding: 5,
            hPadding: 10
          )
      }
    }
  }
}

#Preview {
  MedalDetailTagsSection()
}
