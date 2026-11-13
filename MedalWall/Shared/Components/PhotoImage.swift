//
//  PhotoImage.swift
//  MedalWall
//
//  Created by Quien on 2026-08-28.
//

import CachedAsyncImage
import SwiftUI

/// Renders a photo at its asset's size and shape, falling back to that asset's
/// placeholder when there is nothing to show.
///
/// Use `init(photo:as:)` for a locally held `UIImage` (e.g. an edit draft), or
/// `init(urlString:as:)` for a remote URL loaded via `CachedAsyncImage`. Pass `placeholderText`
/// to label the placeholder, such as a medal's face. Inside a skeleton the photo is one bone in
/// its shape, with no placeholder glyph or spinner.
struct PhotoImage: View {
  private let photo: UIImage?
  private let urlString: String?
  private let imageType: ImageType
  private let placeholderText: LocalizedStringKey?

  /// Displays a locally held UIImage, falling back to the placeholder if nil.
  init(photo: UIImage?, as imageType: ImageType, placeholderText: LocalizedStringKey? = nil) {
    self.photo = photo
    self.urlString = nil
    self.imageType = imageType
    self.placeholderText = placeholderText
  }

  /// Fetches and displays an image from a URL string, falling back to the placeholder if
  /// nil or loading fails.
  init(urlString: String?, as imageType: ImageType, placeholderText: LocalizedStringKey? = nil) {
    self.photo = nil
    self.urlString = urlString
    self.imageType = imageType
    self.placeholderText = placeholderText
  }

  var body: some View {
    Group {
      if let photo {
        styled(Image(uiImage: photo))
      } else if let urlString, let url = URL(string: urlString) {
        CachedAsyncImage(url: url, targetSize: imageType.size) { phase in
          switch phase {
          case .success(let image):
            styled(image)
          default:
            PlaceholderImage(as: imageType, text: placeholderText)
              .overlay {
                if case .empty = phase { ProgressView() }
              }
          }
        }
      } else {
        PlaceholderImage(as: imageType, text: placeholderText)
      }
    }  // Group
    .skeletonBone(imageType.shape)
  }

  /// Renders a real image at this asset's size and shape.
  private func styled(_ image: Image) -> some View {
    image
      .resizable()
      .scaledToFill()
      .frame(width: imageType.size.width, height: imageType.size.height)
      .clipShape(imageType.shape)
  }
}

#Preview("Image Photo") {
  VStack(spacing: 20) {
    PhotoImage(photo: UIImage(named: "taipei-marathon"), as: .raceHero)

    PhotoImage(photo: UIImage(named: "taipei-marathon-2019"), as: .avatar)
  }  // VStack
  .padding(40)
  .background(Color.Background.primary)
}

#Preview("Skeleton") {
  VStack(spacing: 20) {
    PhotoImage(photo: nil, as: .avatar)

    PhotoImage(photo: nil, as: .raceThumbnail)

    PhotoImage(photo: nil, as: .medalThumbnail)
  }  // VStack
  .padding(40)
  .background(Color.Background.primary)
  .redacted(reason: .placeholder)
}
