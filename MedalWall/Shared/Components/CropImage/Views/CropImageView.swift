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
        let containerSize = geo.size

        VStack {
          Spacer()

          ZStack {
            if let uiImage = image {
              Image(uiImage: uiImage)
                .resizable()
                .scaledToFill()
                .scaleEffect(scale)
                .offset(offset)
                .gesture(
                  // Drag
                  DragGesture()
                    .onChanged { value in
                      offset = CGSize(
                        width: value.translation.width + lastOffset.width,
                        height: value.translation.height + lastOffset.height
                      )
                    }
                    .onEnded { _ in
                      let clamped = clampOffset(
                        offset,
                        scale: scale,
                        cropSize: cropSize,
                        containerSize: containerSize
                      )
                      withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        offset = clamped
                      }
                      lastOffset = offset
                    }
                )
                .gesture(
                  // Zoom
                  MagnificationGesture()
                    .onChanged { value in
                      scale = value + lastScale
                    }
                    .onEnded { _ in
                      let rendered = renderedImageSize(containerSize: containerSize)
                      // Minimum scale: the smaller side of the image just touches the crop hole edge.
                      let minScale = max(
                        cropSize.width / rendered.width, cropSize.height / rendered.height)
                      let clampedScale = max(minScale, scale)
                      let clampedOffset = clampOffset(
                        offset, scale: clampedScale, cropSize: cropSize,
                        containerSize: containerSize)
                      withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        scale = clampedScale
                        offset = clampedOffset
                      }
                      lastScale = clampedScale - 1
                      lastOffset = clampedOffset
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
          }  // ZStack
          .frame(width: geo.size.width, height: geo.size.height)
          .clipped()

          Spacer()
        }  // VStack
        .navigationTitle("Crop your photo")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
          ToolbarItem(placement: .cancellationAction) {
            Button(role: .close) {
              dismiss()
            }
          }  // ToolbarItem
          ToolbarItem(placement: .confirmationAction) {
            Button(role: .confirm) {
              onCrop(cropImage(cropSize: cropSize, containerSize: containerSize))
              dismiss()
            }
          }  // ToolbarItem
        }  // toolbar
      }  // GeometryReader
    }  // NavigationStack
  }

  // MARK: - Private functions
  // The size scaledToFill renders the image at inside containerSize.
  // scaledToFill picks the axis whose scale factor is larger, so one dimension
  // matches the container and the other overflows — this overflow is what the
  // user drags/zooms to reposition.
  private func renderedImageSize(containerSize: CGSize) -> CGSize {
    guard let uiImage = image else { return containerSize }

    let imageRatio = uiImage.size.width / uiImage.size.height
    let containerRatio = containerSize.width / containerSize.height
    if imageRatio > containerRatio {
      // Landscape relative to container — constrained by height
      return CGSize(width: containerSize.height * imageRatio, height: containerSize.height)
    } else {
      // Portrait relative to container — constrained by width
      return CGSize(width: containerSize.width, height: containerSize.width / imageRatio)
    }
  }

  // Returns the offset clamped so the image never exposes empty space inside the crop hole.
  // Uses the actual scaledToFill rendered size, not containerSize, because a landscape image
  // renders wider than the container and must be allowed to shift further horizontally.
  // maxOffset = (renderedSize * scale - cropSize) / 2
  private func clampOffset(
    _ offset: CGSize, scale: CGFloat, cropSize: CGSize, containerSize: CGSize
  ) -> CGSize {
    let rendered = renderedImageSize(containerSize: containerSize)
    let maxX = (rendered.width * scale - cropSize.width) / 2
    let maxY = (rendered.height * scale - cropSize.height) / 2
    return CGSize(
      width: min(maxX, max(-maxX, offset.width)),
      height: min(maxY, max(-maxY, offset.height))
    )
  }

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
      let cgImage = full.cgImage
    else { return nil }

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
