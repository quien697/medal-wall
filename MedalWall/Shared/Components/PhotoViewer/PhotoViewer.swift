//
//  PhotoViewer.swift
//  MedalWall
//
//  Created by Quien on 2026-04-17.
//

import SwiftUI

struct PhotoViewer: View {
  @Environment(\.dismiss) private var dismiss
  let photos: [UIImage]
  @Binding var selectedIndex: Int
  
  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()
      
      TabView(selection: $selectedIndex) {
        ForEach(photos.indices, id: \.self) { index in
          Image(uiImage: photos[index])
            .resizable()
            .aspectRatio(contentMode: .fit)
            .tag(index)
        }
      }
      .tabViewStyle(.page(indexDisplayMode: .never))
      .ignoresSafeArea()
      
      VStack {
        PhotoViewerHeader(onClose: { dismiss() })
        
        Spacer()
        
        PhotoViewerFooter(photos: photos, selectedIndex: $selectedIndex)
      } // VStack
    }
  }
}
