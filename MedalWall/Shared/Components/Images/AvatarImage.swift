//
//  AvatarImage.swift
//  MedalWall
//
//  Created by Quien on 2026-01-08.
//

import CachedAsyncImage
import SwiftUI

/// Circular avatar component.
/// Use `init(photo:)` for a local `UIImage` (e.g. edit profile draft),
/// or `init(photoUrl:)` for a remote URL loaded via `CachedAsyncImage`.
/// Falls back to a person placeholder when no image is available.
struct AvatarImage: View {
  private let systemImageName: String = "person.fill"
  private let photo: UIImage?
  private let photoUrl: String?
  private let imageType: ImageType

  init(photo: UIImage?, imageType: ImageType = .avatar) {
    self.photo = photo
    self.photoUrl = nil
    self.imageType = imageType
  }

  init(photoUrl: String?, imageType: ImageType = .avatar) {
    self.photo = nil
    self.photoUrl = photoUrl
    self.imageType = imageType
  }

  var body: some View {
    if let uiImage = photo {
      Image(uiImage: uiImage)
        .styled(as: imageType)
    } else if let urlString = photoUrl, let url = URL(string: urlString) {
      CachedAsyncImage(url: url, targetSize: imageType.size) { phase in
        switch phase {
        case .empty:
          ProgressView()
            .scaleEffect(imageType == .avatarThumbnail ? 0.6 : 1.0)
            .frame(width: imageType.size.width, height: imageType.size.height)
        case .success(let image):
          image.styled(as: imageType)
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
      .font(.system(size: imageType.size.width / 2, weight: .semibold))
      .foregroundStyle(Color.Text.secondary)
      .frame(width: imageType.size.width, height: imageType.size.height)
      .background(Color.Surface.tertiary)
      .clipShape(imageType.shape)
      .overlay(imageType.shape.stroke(Color.Pigment.pewter, lineWidth: 1.5))
  }
}

#Preview {
  AvatarImage(photo: UIImage(named: "quien"))
  AvatarImage(photo: UIImage(named: "taipei-marathon-medal-2019"))
  AvatarImage(photo: nil)

  AvatarImage(
    photo: UIImage(named: "quien"),
    imageType: .avatarThumbnail
  )
  AvatarImage(
    photo: UIImage(named: "taipei-marathon-medal-2019"),
    imageType: .avatarThumbnail
  )
  AvatarImage(
    photo: nil,
    imageType: .avatarThumbnail
  )
}
