//
//  RaceRowView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-11.
//

import SwiftUI

struct RaceRow: View {
  let photo: UIImage?
  let name: String
  let location: String
  let editionCount: Int
  
  var body: some View {
    HStack {
      if let photo {
        Image(uiImage: photo)
          .styled(as: ImageType.raceThumbnail)
      } else {
        Image(systemName: "photo.fill")
          .placeholderStyled(as: ImageType.raceThumbnail)
      }
      
      VStack(alignment: .leading) {
        Text(name)
          .font(.headline)
          .foregroundStyle(Color.Text.primary)
        
        Text(location)
          .font(.subheadline)
          .foregroundStyle(Color.Text.secondary)
        
        Text("\(editionCount) editions")
          .font(.subheadline)
          .foregroundStyle(Color.Text.tertiary)
      }
    }
  }
}

#Preview {
  let race = Race.sampleData.first!
  
  List {
    RaceRow(
      photo: race.cropPhoto ?? race.photo,
      name: race.name,
      location: race.location.formatted,
      editionCount: race.editions.count
    )
  }
}
