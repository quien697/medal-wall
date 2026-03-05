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
          width: ImageType.avatar.size.width * 1.1,
          height: ImageType.avatar.size.height * 1.1
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
          width: ImageType.avatar.size.width,
          height: ImageType.avatar.size.height
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
              .avatar()
          } else {
            Image(systemName: systemImageName)
              .font(.system(size: 50, weight: .semibold))
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
}
