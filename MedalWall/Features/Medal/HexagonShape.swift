//
//  HexagonShape.swift
//  MedalWall
//
//  Created by Quien on 2025-12-17.
//

import SwiftUI

struct Hexagon: Shape {
  static let aspectRatio: CGFloat = 2 / sqrt(3)
  
  func path(in rect: CGRect) -> Path {
    var path = Path()
    
    let center = CGPoint(x: rect.midX, y: rect.midY)
    let width = min(rect.width, rect.height * Self.aspectRatio)
    let size = width / 2
    let corners = (0..<6)
      .map {
        let angle = -CGFloat.pi / 3 * CGFloat($0)
        let dx = size * cos(angle)
        let dy = size * sin(angle)
        
        return CGPoint(x: center.x + dx, y: center.y + dy)
      }
    
    path.move(to: corners[0])
    corners[1..<6].forEach { point in
      path.addLine(to: point)
    }
    
    path.closeSubpath()
    
    return path
  }
}
