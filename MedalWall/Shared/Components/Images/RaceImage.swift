//
//  RaceImage.swift
//  MedalWall
//
//  Created by Quien on 2026-04-17.
//

import SwiftUI

struct RaceImage: View {
  private let systemImageName: String = "person.fill"
  private let photo: UIImage?
  private let urlString: String?
  private let imageType: ImageType
  
  /// Displays a locally held UIImage, falling back to the placeholder if nil.
  init(photo: UIImage?, imageType: ImageType) {
    self.photo = photo
    self.urlString = nil
    self.imageType = imageType
  }
  
  /// Fetches and displays an image from a URL string, falling back to the placeholder if nil or loading fails.
  init(urlString: String?, imageType: ImageType) {
    self.photo = nil
    self.urlString = urlString
    self.imageType = imageType
  }
  
  var body: some View {
    if let photo {
      Image(uiImage: photo)
        .styled(as: imageType)
    } else if let urlString, let url = URL(string: urlString) {
      AsyncImage(url: url) { phase in
        switch phase {
        case .success(let image):
          image.styled(as: imageType)
        default:
          Image(systemName: systemImageName)
            .placeholderStyled(as: imageType)
            .overlay {
              if case .empty = phase { ProgressView() }
            }
        }
      }
    } else {
      Image(systemName: systemImageName)
        .placeholderStyled(as: imageType)
    }
  }
}

#Preview {
  RaceImage(urlString: nil, imageType: .raceHero)
  RaceImage(urlString: nil, imageType: .raceThumbnail)
}
