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
  let imageType: ImageType
  
  init(
    photo: UIImage?,
    imageType: ImageType = .avatar
  ) {
    self.photo = photo
    self.imageType = imageType
  }
  
  var body: some View {
    ZStack {
      // Outer ring/border
      Circle()
        .fill(
          LinearGradient(
            colors: [
              Color.Gold.primary,
              Color.Gold.secondary
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
              Color.Gold.primary,
              Color.Gold.secondary
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
          color: Color.Gold.primary.opacity(0.5),
          radius: 8,
          x: 0,
          y: 10
        )
        .overlay {
          if let uiImage = photo {
            Image(uiImage: uiImage)
              .styled(as: imageType)
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
