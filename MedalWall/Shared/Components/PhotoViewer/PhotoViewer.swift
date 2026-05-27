//
//  PhotoViewer.swift
//  MedalWall
//
//  Created by Quien on 2026-04-17.
//

import SwiftUI

struct PhotoViewer: View {
  @Environment(\.dismiss) private var dismiss
  let photos: [String]
  @Binding var selectedIndex: Int

  var body: some View {
    ZStack {
      Color.black.ignoresSafeArea()

      TabView(selection: $selectedIndex) {
        ForEach(photos.indices, id: \.self) { index in
          AsyncImage(url: URL(string: photos[index])) { phase in
            switch phase {
            case .success(let image):
              image
                .resizable()
                .aspectRatio(contentMode: .fit)
            default:
              ProgressView()
                .tint(.white)
            }
          }
          .tag(index)
        }  // ForEach
      }  // TabView
      .tabViewStyle(.page(indexDisplayMode: .never))
      .ignoresSafeArea()

      VStack {
        PhotoViewerHeader(onClose: { dismiss() })

        Spacer()

        PhotoViewerFooter(photos: photos, selectedIndex: $selectedIndex)
      }  // VStack
    }  // ZStack
  }
}
