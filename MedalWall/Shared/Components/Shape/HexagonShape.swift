//
//  HexagonShape.swift
//  MedalWall
//
//  Created by Quien on 2025-12-17.
//

import SwiftUI

struct Hexagon: Shape {
  /// Controls where the side vertices sit vertically.
  /// 0.25 = regular hexagon, lower = sharper top/bottom points.
  private let sideRatio: CGFloat = 0.21
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    
    let w = rect.width
    let h = rect.height
    
    // Pointy-top hexagon with sharper top/bottom angles
    let points = [
      CGPoint(x: w * 0.5, y: 0),              // top
      CGPoint(x: w, y: h * sideRatio),        // upper-right
      CGPoint(x: w, y: h * (1 - sideRatio)),  // lower-right
      CGPoint(x: w * 0.5, y: h),              // bottom
      CGPoint(x: 0, y: h * (1 - sideRatio)),  // lower-left
      CGPoint(x: 0, y: h * sideRatio),        // upper-left
    ]
    
    path.move(to: points[0])
    for point in points.dropFirst() {
      path.addLine(to: point)
    }
    path.closeSubpath()
    
    return path
  }
}

#Preview {
  Hexagon()
    .frame(width: 200 * 0.9, height: 200)
}
