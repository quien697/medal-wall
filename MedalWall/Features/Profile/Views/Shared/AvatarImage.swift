//
//  AvatarImage.swift
//  MedalWall
//
//  Created by Quien on 2026-01-08.
//

import SwiftUI

struct AvatarImage: View {
  private let systemImageName: String = "person.fill"
  let photo: UIImage?
  let cropPhoto: UIImage?
  let imageType: ImageType
  
  init(
    photo: UIImage?,
    cropPhoto: UIImage?,
    imageType: ImageType = .avatar
  ) {
    self.photo = photo
    self.cropPhoto = cropPhoto
    self.imageType = imageType
  }
  
  var body: some View {
    ZStack {
      // Outer ring/border
      Circle()
        .fill(
          LinearGradient(
            colors: [
              Color("BadgeGoldPrimary"),
              Color("BadgeGoldSecondary")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
        .frame(
          width: imageType.size.width * 1.1,
          height: imageType.size.height * 1.1
        )
      
      // Inner circle
      Circle()
        .fill(
          LinearGradient(
            colors: [
              Color("BadgeGoldPrimary"),
              Color("BadgeGoldSecondary")
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
        .frame(
          width: imageType.size.width,
          height: imageType.size.height
        )
        .shadow(
          color: Color("BadgeGoldPrimary").opacity(0.5),
          radius: 8,
          x: 0,
          y: 10
        )
        .overlay {
          if let uiImage = cropPhoto ?? photo {
            Image(uiImage: uiImage)
              .avatar(type: imageType)
          } else {
            Image(systemName: systemImageName)
              .font(.system(size: imageType.size.width / 2, weight: .semibold))
              .foregroundColor(.white)
          }
        }
    }
  }
}

#Preview {
  AvatarImage(photo: UIImage(named: "quien"), cropPhoto: nil)
  AvatarImage(photo: UIImage(named: "taipei-marathon-2020"), cropPhoto: nil)
  AvatarImage(photo: nil, cropPhoto: nil)
  
  AvatarImage(
    photo: UIImage(named: "quien"),
    cropPhoto: nil,
    imageType: .avatarThumbnail
  )
  AvatarImage(
    photo: UIImage(named: "taipei-marathon-2020"),
    cropPhoto: nil,
    imageType: .avatarThumbnail
  )
  AvatarImage(
    photo: nil,
    cropPhoto: nil,
    imageType: .avatarThumbnail
  )
}
