//
//  MedalImage.swift
//  MedalWall
//
//  Created by Quien on 2025-12-30.
//

import SwiftUI

struct MedalImage: View {
  private let systemImageName: String = "medal.fill"
  private let imageType: ImageType = .medal
  
  let size: CGFloat
  let photo: UIImage?
  
  init(
    photo: UIImage? = nil,
  ) {
    self.photo = photo
    self.size = imageType.size.width
  }
  
  var body: some View {
    ZStack {
      Hexagon()
        .stroke(
          LinearGradient(
            stops: [
              .init(color: Color.Badge.Gold.secondary, location: 0.0),
              .init(color: Color.Badge.Gold.primary, location: 0.35),
              .init(color: Color.Badge.Gold.secondary, location: 0.5),
              .init(color: Color.Badge.Gold.primary, location: 0.75),
              .init(color: Color.Badge.Gold.secondary.opacity(0.8), location: 1.0),
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          style: StrokeStyle(
            lineWidth: max(1, size * 0.06),
            lineJoin: .round
          )
        )
        .overlay(
          Hexagon()
            .stroke(
              Color.Badge.Gold.secondary.opacity(0.2),
              lineWidth: 1
            )
        )
        .shadow(
          color: Color.Badge.Gold.primary.opacity(0.25),
          radius: 3,
          x: 0,
          y: 2
        )
        .frame(width: size * 0.9, height: size)
      
      if let uiImage = photo {
        Image(uiImage: uiImage)
          .resizable()
          .aspectRatio(contentMode: imageType.contentMode)
          .frame(width: size * 0.78, height: size * 0.78)
          .clipShape(imageType.shape)
          .shadow(
            radius: 6,
            x: 6,
            y: 6
          )
      } else {
        Image(systemName: systemImageName)
          .font(.system(size: size * 0.3, weight: .semibold))
          .foregroundColor(Color.Badge.Gold.primary)
      }
    } // ZStack
    .padding(0)
  }
}

#Preview {
  VStack(spacing: 20) {
    MedalImage(photo: nil)
    
    MedalImage(
      photo: UIImage(named: "bmo-vancouver-marathon-2022")
    )
  }
}
