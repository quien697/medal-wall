//
//  CropImageView.swift
//  MedalWall
//
//  Created by Quien on 2026-01-10.
//

import SwiftUI

struct CropImageView: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss
  // MARK: - State
  @State private var scale: CGFloat = 1.0
  @State private var lastScale: CGFloat = 0
  @State private var offset: CGSize = .zero
  @State private var lastOffset: CGSize = .zero
  // MARK: - Properties
  let image: UIImage?
  let cropShape: CropImageShape
  let onCrop: (UIImage?) -> Void
  
  // MARK: - Body
  var body: some View {
    NavigationStack {
      GeometryReader { geo in
        let side = min(geo.size.width * 0.75, 400)
        let cropSize = CGSize(width: side, height: side)
        
        VStack {
          Spacer()
          
          Text("Move and Scale")
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
          
          ZStack {
            if let uiImage = image {
              Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                  DragGesture()
                    .onChanged { value in
                      offset = CGSize(
                        width: value.translation.width + lastOffset.width,
                        height: value.translation.height + lastOffset.height
                      )
                    }
                    .onEnded { _ in
                      lastOffset = offset
                    }
                )
                .gesture(
                  MagnificationGesture()
                    .onChanged { value in
                      scale = value + lastScale
                    }
                    .onEnded { _ in
                      lastScale = scale - 1
                      lastOffset = offset
                    }
                )
            }
            
            Rectangle()
              .fill(.black.opacity(0.5))
              .overlay {
                CropImageShapeView(shape: cropShape, size: cropSize)
                  .blendMode(.destinationOut)
              }
              .compositingGroup()
              .allowsHitTesting(false)
          } // ZStack
          .frame(width: geo.size.width, height: geo.size.height)
          .clipped()
        } // VStack
        .frame(width: geo.size.width, height: geo.size.height)
        .navigationTitle("Crop your photo")
        .navigationBarTitleDisplayMode(.inline)
        .background(.black)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button(role: .close) {
              dismiss()
            }
          } // ToolbarItem
          ToolbarItem(placement: .confirmationAction) {
            Button(role: .confirm) {
              onCrop(cropImage(cropSize: cropSize, containerSize: geo.size))
              dismiss()
            }
          } // ToolbarItem
        } // toolbar
      } // GeometryReader
    } // NavigationStack
  }
  
  // MARK: - Private functions
  
  private func cropImage(cropSize: CGSize, containerSize: CGSize) -> UIImage? {
    guard let uiImage = image else { return nil }
    
    // Render the full container, not just cropSize. The user's scale and offset were
    // applied relative to containerSize, so rendering at a smaller frame would shift
    // the scaledToFill baseline and produce a misaligned result.
    let view = Image(uiImage: uiImage)
      .resizable()
      .scaledToFill()
      .scaleEffect(scale)
      .offset(offset)
      .frame(width: containerSize.width, height: containerSize.height)
      .clipped()
    let renderer = ImageRenderer(content: view)
    
    guard let full = renderer.uiImage,
          let cgImage = full.cgImage else { return nil }
    
    // CGImage works in pixels, not points, so all values must be multiplied by scale.
    let fullScale = full.scale
    // The crop hole is centered in the container, so its top-left corner in points is
    // (containerSize - cropSize) / 2. Multiply by fullScale to convert points → pixels.
    let rect = CGRect(
      x: (containerSize.width - cropSize.width) / 2 * fullScale,
      y: (containerSize.height - cropSize.height) / 2 * fullScale,
      width: cropSize.width * fullScale,
      height: cropSize.height * fullScale
    )
    guard let cropped = cgImage.cropping(to: rect) else { return nil }
    // Pass scale and orientation back so UIImage renders correctly on any device.
    return UIImage(cgImage: cropped, scale: fullScale, orientation: full.imageOrientation)
  }
}

#Preview {
  CropImageView(
    image: UIImage(named: "bmo-vancouver-marathon"),
    cropShape: .circle,
    onCrop: { _ in }
  )
}
