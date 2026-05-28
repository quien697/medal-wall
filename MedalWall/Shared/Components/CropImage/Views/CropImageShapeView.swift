//
//  CropImageShapeView.swift
//  MedalWall
//
//  Created by Quien on 2026-04-24.
//

import SwiftUI

struct CropImageShapeView: View {
  let shape: CropImageShape
  let size: CGSize

  var body: some View {
    switch shape {
    case .circle:
      Circle().frame(width: size.width, height: size.height)
    case .square:
      Rectangle().frame(width: size.width, height: size.height)
    }
  }
}

#Preview {
  CropImageShapeView(shape: .circle, size: CGSize(width: 160, height: 160))
}
