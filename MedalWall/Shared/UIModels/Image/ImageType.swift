//
//  ImageType.swift
//  MedalWall
//
//  Created by Quien on 2026-01-20.
//

import SwiftUI

enum ImageType {
  // Profile
  case avatar
  
  // Race
  case raceThumbnail
  case raceHero
  
  // Medal
  case medal
}

extension ImageType {
  var contentMode: ContentMode {
    switch self {
    case .avatar, .medal, .raceHero, .raceThumbnail:
      return .fill
    }
  }
  
  var shape: AnyShape {
    switch self {
    case .avatar, .medal:
      return AnyShape(Circle())
    case .raceThumbnail, .raceHero:
      return AnyShape(.rect(cornerRadius: 12))
    }
  }
  
  var size: CGSize {
    switch self {
    case .avatar:
      return CGSize(width: 100, height: 100)
    case .raceThumbnail:
      return CGSize(width: 60, height: 60)
    case .raceHero:
      return CGSize(width: 240, height: 240)
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
}

extension Image {
  
  func avatar() -> some View {
    self.styled(as: .avatar)
  }
  
  func raceThumbnail() -> some View {
    self.styled(as: .raceThumbnail)
  }
  
  func raceHero() -> some View {
    self.styled(as: .raceHero)
  }
}
