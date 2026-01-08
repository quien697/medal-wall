//
//  MedalBadge.swift
//  MedalWall
//
//  Created by Quien on 2025-12-30.
//

import SwiftUI

struct MedalBadge: View {
  private let systemImageName: String = "medal.fill"
  private let strokeColor: Color = .black
  private let gradientColors: [Color]
  
  let size: CGFloat
  let photo: UIImage?
  
  init(
    size: CGFloat = 160,
    photo: UIImage? = nil,
  ) {
    self.size = size
    self.photo = photo
    self.gradientColors = [
      strokeColor.opacity(0.8),
      strokeColor.opacity(0.3)
    ]
  }
  
  var body: some View {
    ZStack {
      Hexagon()
        .stroke(
          LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing),
          lineWidth: max(1, size * 0.05)
        )
        .overlay(
          Hexagon()
            .stroke(strokeColor.opacity(0.1), lineWidth: 2)
        )
        .frame(width: size, height: size)
      
      if let uiImage = photo {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFill()
          .frame(width: size * 0.7, height: size * 0.7)
          .clipShape(Circle())
          .shadow(radius: 4)
      } else {
        Image(systemName: systemImageName)
          .font(.system(size: size * 0.3, weight: .semibold))
          .foregroundColor(.gray)
      }
    } // ZStack
    .padding(0)
  }
}

#Preview {
  let size: CGFloat = 160
  
  VStack(spacing: 20) {
    MedalBadge(
      size: size,
      photo: nil
    )
    
    MedalBadge(
      size: size,
      photo: UIImage(named: "bmo-vancouver-marathon-2022")
    )
  }
}
