//
//  HexagonShape.swift
//  MedalWall
//
//  Created by Quien on 2025-12-17.
//

import SwiftUI

struct Hexagon: InsettableShape {
  /// Controls where the side vertices sit vertically.
  /// 0.25 = regular hexagon, lower = sharper top/bottom points.
  private let sideRatio: CGFloat = 0.21
  private var insetAmount: CGFloat = 0

  func path(in rect: CGRect) -> Path {
    let insetRect = rect.insetBy(dx: insetAmount, dy: insetAmount)

    var path = Path()

    let w = insetRect.width
    let h = insetRect.height
    let originX = insetRect.minX
    let originY = insetRect.minY

    // Pointy-top hexagon with sharper top/bottom angles
    let points = [
      CGPoint(x: originX + w * 0.5, y: originY),  // top
      CGPoint(x: originX + w, y: originY + h * sideRatio),  // upper-right
      CGPoint(x: originX + w, y: originY + h * (1 - sideRatio)),  // lower-right
      CGPoint(x: originX + w * 0.5, y: originY + h),  // bottom
      CGPoint(x: originX, y: originY + h * (1 - sideRatio)),  // lower-left
      CGPoint(x: originX, y: originY + h * sideRatio),  // upper-left
    ]

    path.move(to: points[0])
    for point in points.dropFirst() {
      path.addLine(to: point)
    }
    path.closeSubpath()

    return path
  }

  func inset(by amount: CGFloat) -> some InsettableShape {
    var shape = self
    shape.insetAmount += amount
    return shape
  }
}

#Preview {
  VStack {
    Hexagon()
      .frame(width: 200 * 0.9, height: 200)
  }
  .background(.blue)
}
