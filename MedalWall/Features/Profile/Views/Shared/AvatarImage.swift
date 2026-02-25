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
    if let uiImage = cropPhoto ?? photo {
      Image(uiImage: uiImage)
        .avatar()
    } else {
      Circle()
        .fill(Color(.systemGray5))
        .frame(
          width: ImageType.avatar.size.width,
          height: ImageType.avatar.size.height
        )
        .overlay {
          Image(systemName: systemImageName)
            .font(.system(size: 50, weight: .semibold))
            .foregroundColor(.gray)
        }
    }
  }
}


#Preview {
  AvatarImage(photo: UIImage(named: "quien"), cropPhoto: nil)
  
  AvatarImage(photo: nil, cropPhoto: nil)
}
