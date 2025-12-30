//
//  MedalBadgeView.swift
//  MedalWall
//
//  Created by Quien on 2025-12-30.
//

import SwiftUI

struct MedalBadgeView: View {
  private let systemImageName: String = "medal.fill"
  private let gradientColors: [Color]
  private let strokeColor: Color = .black.opacity(0.1)
  
  let size: CGFloat
  let photo: UIImage?
  let color: Color
  
  init(
    size: CGFloat = 160,
    photo: UIImage? = nil,
    color: Color,
  ) {
    self.size = size
    self.photo = photo
    self.color = color
    self.gradientColors = [
      color.opacity(0.8),
      color.opacity(0.5)
    ]
  }
  
  var body: some View {
    ZStack {
      Hexagon()
        .fill(
          LinearGradient(
            colors: gradientColors,
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          )
        )
        .overlay(
          Hexagon()
            .stroke(strokeColor, lineWidth: 2)
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
          .foregroundColor(.white)
      }
    } // ZStack
  }
}

#Preview(traits: .sampleData) {
  let size: CGFloat = 160
  
  VStack(spacing: 20) {
    MedalBadgeView(
      size: size,
      photo: nil,
      color: .orange
    )
    
    MedalBadgeView(
      size: size,
      photo: UIImage(named: "bmo-vancouver-marathon-2022"),
      color: .blue
    )
  }
}
