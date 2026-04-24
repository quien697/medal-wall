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
      RaceImage(
        photo: photo,
        imageType: .raceThumbnail
      )
      
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
    } // HStack
  }
}

#Preview {
  let race = Race.sampleData.first!
  
  List {
    RaceRow(
      photo: race.photo,
      name: race.name,
      location: race.location.formatted,
      editionCount: race.editions.count
    )
  }
}
