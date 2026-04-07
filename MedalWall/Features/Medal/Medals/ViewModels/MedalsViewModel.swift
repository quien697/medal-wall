//
//  MedalsViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-04-03.
//

import SwiftUI

@Observable
final class MedalsViewModel {
  // MARK: - Properties
  
  let gridSpacing: CGFloat = 10
  
  // MARK: - Computed
  var gridColumns: [GridItem] {
    [GridItem](
     repeating: GridItem(.flexible(minimum: 80), spacing: gridSpacing),
     count: 2
   )
  }
  
  /// Calculate medal image size that fits within the grid item's content area.
  /// Hexagon width = size * 0.9, so size = contentWidth / 0.9.
  /// Capped at the default medal size for larger screens.
//  func imageSize(for availableWidth: CGFloat) -> CGFloat {
//    let itemWidth = (availableWidth - spacing * CGFloat(columnCount + 1)) / CGFloat(columnCount)
//    let contentWidth = itemWidth - surfacePadding * 2
//    return min(ImageType.medal.size.width, contentWidth / 0.9)
//  }
}
