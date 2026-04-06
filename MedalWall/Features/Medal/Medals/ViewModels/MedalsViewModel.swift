//
//  MedalsViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-04-03.
//

import SwiftUI

@Observable
final class MedalsViewModel {
  let columnCount: Int = 2
  let spacing: CGFloat = 10
  
  // Search
  var searchText: String = ""
//  let surfacePadding: CGFloat = 15
  
  /// Calculate medal image size that fits within the grid item's content area.
  /// Hexagon width = size * 0.9, so size = contentWidth / 0.9.
  /// Capped at the default medal size for larger screens.
//  func imageSize(for availableWidth: CGFloat) -> CGFloat {
//    let itemWidth = (availableWidth - spacing * CGFloat(columnCount + 1)) / CGFloat(columnCount)
//    let contentWidth = itemWidth - surfacePadding * 2
//    return min(ImageType.medal.size.width, contentWidth / 0.9)
//  }
}
