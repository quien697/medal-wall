//
//  ImageType.swift
//  MedalWall
//
//  Created by Quien on 2026-04-17.
//

import SwiftUI

enum ImageType {
  // Profile
  case avatarThumbnail
  case avatar

  // Race
  case raceThumbnail
  case raceSearchThumbnail
  case raceHero

  // Medal
  case medalThumbnail
  case medalSearchThumbnail
  case medal
  case eventThumbnail
  case event
}

extension ImageType {
  var shape: AnyShape {
    switch self {
    case .avatarThumbnail, .avatar, .medalThumbnail, .medalSearchThumbnail, .medal:
      return AnyShape(Circle())
    case .raceThumbnail, .raceSearchThumbnail, .raceHero, .eventThumbnail, .event:
      return AnyShape(.rect(cornerRadius: .Radius.image))
    }
  }

  var size: CGSize {
    switch self {
    case .avatarThumbnail: return CGSize(width: 60, height: 60)
    case .avatar: return CGSize(width: 100, height: 100)
    case .raceThumbnail: return CGSize(width: 60, height: 60)
    case .raceSearchThumbnail: return CGSize(width: 52, height: 52)
    case .raceHero: return CGSize(width: 100, height: 100)
    case .medalThumbnail: return CGSize(width: 96, height: 96)
    case .medalSearchThumbnail: return CGSize(width: 46, height: 46)
    case .medal: return CGSize(width: 160, height: 160)
    case .eventThumbnail: return CGSize(width: 100, height: 80)
    case .event: return CGSize(width: 140, height: 110)
    }
  }

  /// The SF Symbol standing in for a missing image, one glyph per asset.
  var placeholderSymbol: String {
    switch self {
    case .avatarThumbnail, .avatar: return "person.fill"
    case .raceThumbnail, .raceSearchThumbnail, .raceHero: return "figure.run"
    case .medalThumbnail, .medalSearchThumbnail, .medal: return "medal.fill"
    case .eventThumbnail, .event: return "photo"
    }
  }
}
