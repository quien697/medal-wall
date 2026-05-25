//
//  PhotoViewerFooter.swift
//  MedalWall
//
//  Created by Quien on 2026-04-18.
//

import SwiftUI

struct PhotoViewerFooter: View {
  let photos: [UIImage]
  @Binding var selectedIndex: Int

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 6) {
          ForEach(photos.indices, id: \.self) { index in
            Image(uiImage: photos[index])
              .resizable()
              .scaledToFill()
              .frame(width: 60, height: 48)
              .clipShape(RoundedRectangle(cornerRadius: 6))
              .overlay(
                RoundedRectangle(cornerRadius: 6)
                  .stroke(
                    selectedIndex == index ? Color.Gold.primary : Color.clear,
                    lineWidth: 2
                  )
              )
              .onTapGesture {
                withAnimation { selectedIndex = index }
              }
              .id(index)
          }  // ForEach
        }  // HStack
        .padding()
      }  // ScrollView
      .onChange(of: selectedIndex) { _, newValue in
        withAnimation {
          proxy.scrollTo(newValue, anchor: .center)
        }
      }
    }  // ScrollViewReader
  }
}

#Preview {
  PhotoViewerFooter(photos: [], selectedIndex: .constant(0))
}
