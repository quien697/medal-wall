//
//  ImageType.swift
//  MedalWall
//
//  Created by Quien on 2026-01-20.
//

import SwiftUI

enum ImageType {
  // Profile
  case avatarThumbnail
  case avatar
  
  // Race
  case raceThumbnail
  case raceHero
  
  // Medal
  case medal
}

extension ImageType {
  var shape: AnyShape {
    switch self {
    case .avatarThumbnail, .avatar, .medal:
      return AnyShape(Circle())
    case .raceThumbnail, .raceHero:
      return AnyShape(.rect(cornerRadius: 16))
    }
  }
  
  var cornerRadius: CGFloat {
    switch self {
    case .avatarThumbnail, .avatar, .medal:
      return size.height / 2
    case .raceThumbnail, .raceHero:
      return 16
    }
  }
  
  var size: CGSize {
    switch self {
    case .avatarThumbnail: return CGSize(width: 60, height: 60)
    case .avatar:          return CGSize(width: 100, height: 100)
    case .raceThumbnail:   return CGSize(width: 60, height: 60)
    case .raceHero:        return CGSize(width: 100, height: 100)
    case .medal:           return CGSize(width: 160, height: 160)
    }
  }
}

extension Image {
  
  func styled(as type: ImageType) -> some View {
    self
      .resizable()
      .scaledToFill()
      .frame(width: type.size.width, height: type.size.height)
      .clipShape(type.shape)
  }
  
  func placeholderStyled(
    as type: ImageType,
    fgColor: Color = Color.Text.tertiary,
    bgColor: Color = Color.Card.Background.tertiary,
    borderColor: Color = Color.Border.gray
  ) -> some View {
    self
      .resizable()
      .scaledToFit()
      .frame(width: type.size.width / 2)
      .foregroundStyle(fgColor)
      .frame(width: type.size.width, height: type.size.height)
      .background(bgColor)
      .clipShape(type.shape)
      .overlay(
        type.shape
          .stroke(borderColor, style: StrokeStyle(lineWidth: 2, dash: [10, 2]))
      )
  }
}
