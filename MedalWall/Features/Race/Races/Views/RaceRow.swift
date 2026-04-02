//
//  RaceRowView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI

struct RaceRow: View {
  let race: Race
  
  var body: some View {
    HStack {
      if let photo = race.cropPhoto ?? race.photo {
        Image(uiImage: photo)
          .styled(as: ImageType.raceThumbnail)
      } else {
        Image(systemName: "photo.fill")
          .placeholderStyled(as: ImageType.raceThumbnail)
      }
      
      VStack(alignment: .leading) {
        Text(race.name)
          .font(.headline)
          .foregroundStyle(Color.Text.primary)
        
        Text(race.location.formatted)
          .font(.subheadline)
          .foregroundStyle(Color.Text.secondary)
        
        Text("\(race.editions.count) editions")
          .font(.subheadline)
          .foregroundStyle(Color.Text.tertiary)
      }
    }
  }
}

#Preview {
  List {
    RaceRow(race: Race.sampleData.first!)
  }
}
