//
//  RaceImage.swift
//  MedalWall
//
//  Created by Quien on 2026-04-17.
//

import SwiftUI

struct RaceImage: View {
  let urlString: String?
  let imageType: ImageType
  
  var body: some View {
    if let urlString, let url = URL(string: urlString) {
      AsyncImage(url: url) { phase in
        switch phase {
        case .empty:
          ProgressView()
        case .success(let image):
          image.styled(as: imageType)
        default:
          Image(systemName: "photo.fill")
            .placeholderStyled(as: imageType)
        }
      }
    } else {
      Image(systemName: "photo.fill")
        .placeholderStyled(as: imageType)
    }
  }
}

#Preview {
  RaceImage(urlString: nil, imageType: .raceHero)
  RaceImage(urlString: nil, imageType: .raceThumbnail)
}
