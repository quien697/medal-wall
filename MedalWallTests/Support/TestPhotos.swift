//
//  TestPhotos.swift
//  MedalWall
//
//  Created by Quien on 2026-11-19.
//

import UIKit

/// Photos built in memory for tests that depend on a photo's pixel size or JPEG size.
enum TestPhotos {
  /// A plain red image of `width` × `height` points at `scale`, which encodes to a small JPEG.
  static func plain(width: CGFloat, height: CGFloat, scale: CGFloat = 1) -> UIImage {
    let format = UIGraphicsImageRendererFormat()
    format.scale = scale
    let size = CGSize(width: width, height: height)
    return UIGraphicsImageRenderer(size: size, format: format).image { context in
      UIColor.red.setFill()
      context.fill(CGRect(origin: .zero, size: size))
    }
  }

  /// A plain photo cropped and checked, as a `PhotoSlot` hands it to a form.
  static func cropped(width: CGFloat = 1, height: CGFloat = 1) throws -> CroppedPhoto {
    try CroppedPhoto(checking: plain(width: width, height: height))
  }

  /// An opaque image of `width` × `height` pixels of seeded random noise, which JPEG cannot
  /// compress: at the default 3840 × 2880 it encodes to a JPEG over 10 MB.
  static func noise(width: Int = 3840, height: Int = 2880) -> UIImage? {
    var bytes = [UInt8](repeating: 0, count: width * height * 4)
    var state: UInt64 = 0x9E37_79B9_7F4A_7C15
    bytes.withUnsafeMutableBytes { buffer in
      let words = buffer.bindMemory(to: UInt64.self)
      for index in words.indices {
        // xorshift64*: fast, and the same noise on every run.
        state ^= state >> 12
        state ^= state << 25
        state ^= state >> 27
        words[index] = state &* 2_685_821_657_736_338_717
      }
    }
    guard let colorSpace = CGColorSpace(name: CGColorSpace.sRGB),
      let provider = CGDataProvider(data: Data(bytes) as CFData),
      let image = CGImage(
        width: width,
        height: height,
        bitsPerComponent: 8,
        bitsPerPixel: 32,
        bytesPerRow: width * 4,
        space: colorSpace,
        bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.noneSkipLast.rawValue),
        provider: provider,
        decode: nil,
        shouldInterpolate: false,
        intent: .defaultIntent
      )
    else { return nil }
    return UIImage(cgImage: image)
  }
}
