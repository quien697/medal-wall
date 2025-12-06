//
//  Image+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2025-11-27.
//

import SwiftUI

enum StyledImageShape {
  case circle
  case rounded(CGFloat)
  case capsule
  
  var shape: AnyShape {
    switch self {
    case .circle:
      AnyShape(Circle())
      
    case .rounded(let radius):
      AnyShape(RoundedRectangle(cornerRadius: radius))
      
    case .capsule:
      AnyShape(Capsule())
    }
  }
}

extension Image {
  
  func styled(
    mode: ContentMode,
    width: CGFloat?,
    height: CGFloat?,
    shape: StyledImageShape
  ) -> some View {
    self
      .resizable()
      .aspectRatio(contentMode: mode)
      .frame(width: width, height: height)
      .clipShape(shape.shape)
  }
}

extension Image {
  
  func raceThumbnail() -> some View {
    self.styled(mode: .fit, width: 60, height: 60, shape: .rounded(12))
  }
  
  func raceHero() -> some View {
    self.styled(mode: .fit, width: 240, height: 240, shape: .rounded(12))
  }
  
  func avatar() -> some View {
    self.styled(mode: .fill, width: 100, height: 100, shape: .circle)
  }
}
