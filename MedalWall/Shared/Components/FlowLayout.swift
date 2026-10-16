//
//  FlowLayout.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI

/// A layout that arranges its children in a flowing manner, wrapping to new lines as needed.
/// Similar to CSS flexbox with flex-wrap: wrap.
///
/// ## How it works:
/// 1. Places subviews horizontally from left to right
/// 2. When a subview doesn't fit in the current line, it wraps to the next line
/// 3. Each line's height is determined by the tallest subview in that line
/// 4. Vertical spacing is added between lines
///
struct FlowLayout: Layout {
  var spacing: CGFloat = 20

  /// Calculates the total size needed to fit all subviews with the flow layout
  /// - Returns: The minimum size that can contain all subviews arranged in flowing lines
  func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
    let result = FlowResult(
      in: proposal.replacingUnspecifiedDimensions().width,
      subviews: subviews,
      spacing: spacing
    )
    return result.size
  }

  /// Positions each subview within the given bounds using the flow layout algorithm
  func placeSubviews(
    in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()
  ) {
    let result = FlowResult(
      in: bounds.width,
      subviews: subviews,
      spacing: spacing
    )
    for (index, subview) in subviews.enumerated() {
      let position = result.positions[index]
      subview.place(
        at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
        proposal: .unspecified
      )
    }
  }

  /// Holds the calculated layout information: total size and position of each subview
  struct FlowResult {
    /// The total size needed to contain all subviews
    var size: CGSize = .zero
    /// The position of each subview in the flow layout
    var positions: [CGPoint] = []

    /// Calculates positions and total size by simulating the flow layout
    /// - Parameters:
    ///   - maxWidth: The maximum width available for the layout
    ///   - subviews: The views to arrange
    ///   - spacing: Vertical spacing between lines and horizontal spacing between each subviews
    init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
      var currentX: CGFloat = 0
      var currentY: CGFloat = 0
      var lineHeight: CGFloat = 0

      for subview in subviews {
        let size = subview.sizeThatFits(.unspecified)

        // Check if this view fits on the current line
        if currentX + size.width > maxWidth && currentX > 0 {
          // Doesn't fit and wrap to next line
          currentX = 0
          currentY += lineHeight + spacing
          lineHeight = 0
        }

        // Place the view at current position
        positions.append(CGPoint(x: currentX, y: currentY))

        lineHeight = max(lineHeight, size.height)
        currentX += size.width + spacing

        self.size.width = max(self.size.width, currentX - spacing)
      }

      self.size.height = currentY + lineHeight
    }
  }
}
