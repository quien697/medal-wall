//
//  LoadingView.swift
//  MedalWall
//
//  Created by Quien on 2026-04-20.
//

import SwiftUI

struct LoadingView: View {
  let text: String
  
  var body: some View {
    VStack(spacing: 16) {
      ProgressView()
        .controlSize(.large)
      
      Text(text)
        .font(.subheadline)
        .foregroundStyle(Color.Text.secondary)
    }
  }
}

#Preview {
  LoadingView(text: "Loading...")
}
