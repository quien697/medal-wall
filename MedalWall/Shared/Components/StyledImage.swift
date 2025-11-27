//
//  StyledImage.swift
//  MedalWall
//
//  Created by Quien on 2025-11-27.
//

import SwiftUI

struct StyledImage: View {
  let image: Image
  let mode: ContentMode
  let width: CGFloat?
  let height: CGFloat?
  let cornerRadius: CGFloat
  
  var body: some View {
    image
      .resizable()
      .scaledToFit()
      .frame(width: width, height: height)
      .clipShape(.rect(cornerRadius: cornerRadius))
  }
}
