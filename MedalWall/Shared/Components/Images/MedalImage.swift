//
//  MedalImage.swift
//  MedalWall
//
//  Created by Quien on 2025-12-30.
//

import CachedAsyncImage
import SwiftUI

struct MedalImage: View {
  private let systemImageName: String = "medal.fill"
  private let imageType: ImageType = .medal
  private let ringWidth: CGFloat = 3
  private let photo: UIImage?
  private let urlString: String?
  private let size: CGFloat

  /// Displays a locally held UIImage (e.g. a newly selected photo not yet uploaded).
  init(photo: UIImage? = nil) {
    self.photo = photo
    self.urlString = nil
    self.size = imageType.size.width
  }

  /// Fetches and displays an image from a URL string, falling back to the placeholder if nil or
  /// loading fails.
  init(urlString: String?) {
    self.photo = nil
    self.urlString = urlString
    self.size = imageType.size.width
  }

  var body: some View {
    photoContent
      .frame(width: size, height: size)
      .clipShape(imageType.shape)
      .padding(ringWidth)
      .background(Circle().fill(Color.Record.primary))
      .elevation(.ring)
  }

  @ViewBuilder
  private var photoContent: some View {
    if let uiImage = photo {
      Image(uiImage: uiImage)
        .resizable()
        .scaledToFill()
    } else if let urlString, let url = URL(string: urlString) {
      CachedAsyncImage(
        url: url,
        targetSize: CGSize(width: size, height: size)
      ) { phase in
        switch phase {
        case .success(let image):
          image
            .resizable()
            .scaledToFill()
        default:
          placeholder
        }
      }
    } else {
      placeholder
    }
  }

  private var placeholder: some View {
    Image(systemName: systemImageName)
      .font(.system(size: size * 0.3, weight: .semibold))
      .foregroundStyle(Color.Text.secondary)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .background(Color.Surface.tertiary)
  }
}

#Preview {
  VStack(spacing: 20) {
    MedalImage(photo: nil)

    MedalImage(
      photo: UIImage(named: "bmo-vancouver-marathon")
    )
  }  // VStack
  .padding(40)
  .background(Color.Background.primary)
}
