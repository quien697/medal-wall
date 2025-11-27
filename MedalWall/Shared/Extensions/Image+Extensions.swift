//
//  Image+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2025-11-27.
//

import SwiftUI

extension Image {
  
  func styled(
    mode: ContentMode,
    width: CGFloat?,
    height: CGFloat?,
    cornerRadius: CGFloat
  ) -> some View {
    self
      .resizable()
      .aspectRatio(contentMode: mode)
      .frame(width: width, height: height)
      .clipShape(.rect(cornerRadius: cornerRadius))
  }
}

extension Image {
  
  func raceThumbnail() -> some View {
    self.styled(mode: .fit, width: 60, height: 60, cornerRadius: 12)
  }
  
  func raceHero() -> some View {
    self.styled(mode: .fit, width: 240, height: 240, cornerRadius: 12)
  }
}
