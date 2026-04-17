//
//  ProfileSummarySection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-05.
//

import SwiftUI

struct ProfileSummarySection: View {
  let columns = [
    GridItem(.flexible(minimum: 80), spacing: 15),
    GridItem(.flexible(minimum: 80), spacing: 15),
    GridItem(.flexible(minimum: 80), spacing: 15),
  ]
  
  var body: some View {
    SectionContainer {
      LazyVGrid(columns: columns, spacing: 20) {
        StatGridItem(title: "32", subTitle: "Races")
        
        StatGridItem(title: "12", subTitle: "Medals", titleColor: Color.Gold.primary)
        
        StatGridItem(title: "847km", subTitle: "Total")
        
        StatGridItem(title: "12", subTitle: "Finisher")
        
        StatGridItem(title: "9:99:99", subTitle: "Best Full", titleColor: Color.Gold.primary)
        
        StatGridItem(title: "2:00:19", subTitle: "Best Half")
      }
    }
  }
}

#Preview {
  ProfileSummarySection()
    .background(Color.Card.Background.tertiary)
}
