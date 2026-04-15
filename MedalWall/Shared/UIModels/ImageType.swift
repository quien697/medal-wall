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
//  case event
}

extension ImageType {
  var contentMode: ContentMode {
    switch self {
    case .avatarThumbnail, .avatar, .medal, .raceHero, .raceThumbnail:
      return .fill
    }
  }
  
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
       return 0
     }
   }
  
  var size: CGSize {
    switch self {
    case .avatarThumbnail:
      return CGSize(width: 60, height: 60)
    case .avatar:
      return CGSize(width: 100, height: 100)
    case .raceThumbnail:
      return CGSize(width: 60, height: 60)
    case .raceHero:
      return CGSize(width: 120, height: 120)
    case .medal:
      return CGSize(width: 160, height: 160)
    }
  }
}

extension Image {
  
  func styled(as type: ImageType) -> some View {
    self
      .resizable()
      .aspectRatio(contentMode: type.contentMode)
      .frame(width: type.size.width, height: type.size.height)
      .clipShape(type.shape)
  }
  
  func placeholderStyled(
    as type: ImageType,
    foregroundColor: Color = Color.Text.tertiary,
    backgroundColor: Color = Color.Card.Background.tertiary,
    borderColor: Color = Color.Border.gray
  ) -> some View {
    self
      .resizable()
      .scaledToFit()
      .frame(width: type.size.width / 2)
      .foregroundStyle(foregroundColor)
      .frame(width: type.size.width, height: type.size.height)
      .background(backgroundColor)
      .clipShape(type.shape)
      .overlay(
        type.shape
          .stroke(borderColor, style: StrokeStyle(lineWidth: 2, dash: [10, 2]))
      )
  }
}
