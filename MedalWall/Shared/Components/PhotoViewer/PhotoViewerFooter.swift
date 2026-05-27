//
//  PhotoViewerFooter.swift
//  MedalWall
//
//  Created by Quien on 2026-04-18.
//

import SwiftUI

struct PhotoViewerFooter: View {
  let photos: [String]
  @Binding var selectedIndex: Int

  var body: some View {
    ScrollViewReader { proxy in
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 6) {
          ForEach(photos.indices, id: \.self) { index in
            AsyncImage(url: URL(string: photos[index])) { phase in
              switch phase {
              case .success(let image):
                image
                  .resizable()
                  .scaledToFill()
              default:
                Color.gray.opacity(0.3)
              }
            }  // ForEach
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
