//
//  TierProgressBar.swift
//  MedalWall
//
//  Created by Quien on 2026-09-01.
//

import SwiftUI

struct TierProgressBar: View {
  let fraction: Double

  var body: some View {
    GeometryReader { proxy in
      ZStack(alignment: .leading) {
        RoundedRectangle(cornerRadius: 3)
          .fill(Color.Surface.tertiary)

        RoundedRectangle(cornerRadius: 3)
          .fill(Color.Record.primary)
          .frame(width: proxy.size.width * fraction)
      }  // ZStack
    }  // GeometryReader
    .frame(height: 6)
  }
}

#Preview {
  VStack {
    TierProgressBar(fraction: 0)
    TierProgressBar(fraction: 1)
  }
  .padding()
  .background(Color.Surface.primary)
}
