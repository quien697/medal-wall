//
//  AvatarImage.swift
//  MedalWall
//
//  Created by Quien on 2026-01-08.
//

import SwiftUI

struct AvatarImage: View {
  private let systemImageName: String = "medal.fill"
  let photo: UIImage?
  
    var body: some View {
      if let uiImage = photo {
        Image(uiImage: uiImage)
          .avatar()
      } else {
        Image(systemName: systemImageName)
          .avatar()
          .foregroundStyle(.gray)
      }
    }
}

#Preview {
  AvatarImage(photo: UIImage(named: "quien"))
}
