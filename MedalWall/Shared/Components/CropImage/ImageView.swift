//
//  ImageView.swift
//  MedalWall
//
//  Created by Quien on 2026-01-22.
//

import SwiftUI

struct ImageView: View {
  @Binding var scale: CGFloat
  @Binding var lastScale: CGFloat
  @Binding var offset: CGSize
  @Binding var lastOffset: CGSize
  
  let image: UIImage?
  let type: ImageType
  
  @GestureState private var isDragging: Bool = false
  private let CROPVIEW: String = "CROPVIEW"
  
  var body: some View {
    GeometryReader { geo in
      if let image {
        Image(uiImage: image)
          .resizable()
          .aspectRatio(contentMode: type.contentMode)
          .overlay {
            GeometryReader { overlayGeo in
              let rect = overlayGeo.frame(in: .named(CROPVIEW))
              
              Color.clear
                .onChange(of: isDragging) { _, newValue in
                  withAnimation(.easeInOut(duration: 0.2)) {
                    if rect.minX > 0 {
                      offset.width = offset.width - rect.minX
                    }
                    if rect.minY > 0 {
                      offset.height = offset.height - rect.minY
                    }
                    if rect.maxX < type.size.width {
                      offset.width = rect.minX - offset.width
                    }
                    if rect.maxY < type.size.height {
                      offset.height = rect.minY - offset.height
                    }
                  }
                  
                  if !newValue {
                    lastOffset = offset
                  }
                }
            }
          } // overlay
          .frame(width: geo.size.width, height: geo.size.height)
      }
    } // GeometryReader
    .offset(offset)
    .scaleEffect(scale)
    .coordinateSpace(name: CROPVIEW)
    .gesture(
      DragGesture()
        .updating($isDragging, body: { _, out, _ in
          out = true
        })
        .onChanged({ value in
          let translation = value.translation
          offset = CGSize(
            width: translation.width + lastOffset.width,
            height: translation.height + lastOffset.height
          )
        })
    ) // gesture
    .gesture(
      MagnificationGesture()
        .updating($isDragging, body: { _, out, _ in
          out = true
        })
        .onChanged({ value in
          let updatedScale = value + lastScale
          scale = (updatedScale < 1 ? 1 : updatedScale)
        })
        .onEnded({ _ in
          withAnimation(.easeIn(duration: 0.2)) {
            if scale < 1 {
              scale = 1
              lastScale = 0
            } else {
              lastScale = scale - 1
            }
          }
        })
    ) // gesture
    .frame(width: type.size.width, height: type.size.height)
    .cornerRadius(type.cornerRadius)
  }
}

#Preview {
  VStack(spacing: 20) {
    ImageView(
      scale: .constant(1.0),
      lastScale: .constant(0),
      offset: .constant(.zero),
      lastOffset: .constant(.zero),
      image: UIImage(named: "bmo-vancouver-marathon-2022"),
      type: .medal,
    )
  }
}
