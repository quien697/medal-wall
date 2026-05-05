//
//  PhotoViewerHeader.swift
//  MedalWall
//
//  Created by Quien on 2026-04-18.
//

import SwiftUI

struct PhotoViewerHeader: View {
  let onClose: () -> Void
  
  var body: some View {
    HStack {
      Spacer()
      
      Button {
        onClose()
      } label: {
        Image(systemName: "xmark")
          .padding(.vertical, 6)
      }
      .buttonStyle(.glass)
    } // HStack
    .padding(.vertical, 8)
    .padding(.horizontal)
  }
}

#Preview {
  VStack {
    Color.black.ignoresSafeArea()
    
    PhotoViewerHeader(onClose: {})
    
    Spacer()
  }
}
