//
//  RaceImage.swift
//  MedalWall
//
//  Created by Quien on 2026-04-17.
//

import SwiftUI

struct RaceImage: View {
  let photo: UIImage?
  let imageType: ImageType
  
  var body: some View {
    if let photo {
      Image(uiImage: photo)
        .styled(as: imageType)
    } else {
      Image(systemName: "photo.fill")
        .placeholderStyled(as: imageType)
    }
  }
}

#Preview {
  RaceImage(photo: nil, imageType: .raceHero)
  RaceImage(photo: nil, imageType: .raceThumbnail)
}
