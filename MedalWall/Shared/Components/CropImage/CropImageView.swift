//
//  CropImageView.swift
//  MedalWall
//
//  Created by Quien on 2026-01-10.
//

import SwiftUI

struct CropImageView: View {
  @Environment(\.dismiss) private var dismiss
  
  @State private var scale: CGFloat = 1.0
  @State private var lastScale: CGFloat = 0
  @State private var offset: CGSize = .zero
  @State private var lastOffset: CGSize = .zero
  @GestureState private var isDragging: Bool = false
  
  let image: UIImage?
  let type: ImageType
  let onCrop: (UIImage?) -> Void
  
  var body: some View {
    let imageView = ImageView(
      scale: $scale,
      lastScale: $lastScale,
      offset: $offset,
      lastOffset: $lastOffset,
      image: image,
      type: type
    )
    
    NavigationStack {
      imageView
      .navigationTitle("Crop Image")
      .navigationBarTitleDisplayMode(.inline)
      .frame(maxWidth: .infinity, maxHeight: .infinity)
      .toolbarColorScheme(.dark, for: .navigationBar)
      .background(.black)
      .toolbar {
        ToolbarItem(placement: .topBarLeading) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
          }
        }
        
        ToolbarItem(placement: .topBarTrailing) {
          Button {
            let renderer = ImageRenderer(content: imageView)
            renderer.proposedSize = .init(type.size)
            if let image = renderer.uiImage {
              onCrop(image)
            } else {
              onCrop(nil)
            }
            
            dismiss()
          } label: {
            Image(systemName: "checkmark")
          }
        }
      }
    } // NavigationStack
  }
}

#Preview {
  CropImageView(
    image: UIImage(named: "bmo-vancouver-marathon"),
    type: .medal,
    onCrop: { _ in }
  )
}
