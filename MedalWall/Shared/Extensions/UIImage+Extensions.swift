//
//  UIImage+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2026-05-20.
//

import UIKit

/// Loading and encoding for photos the user edits, as distinct from photos the app displays.
extension UIImage {

  /// JPEG bytes at the app's upload quality, or nil if the image cannot be encoded.
  ///
  /// The one place that quality is chosen: `StorageService` uploads these bytes, and Edit
  /// ViewModels stage them on a draft before save.
  func uploadData() -> Data? {
    jpegData(compressionQuality: 0.8)
  }

  /// Downloads an image from the given URL string and returns it, or nil if loading fails.
  ///
  /// For a photo the user is about to *edit* — the crop flow needs a `UIImage` value rather
  /// than a view. Display goes through `PhotoImage`, which renders remote URLs via
  /// `CachedAsyncImage`.
  ///
  /// This does not share that cache. It fetches through `URLSession.shared`, so opening an
  /// edit screen re-downloads a photo the display layer may already hold.
  static func load(from urlString: String?) async -> UIImage? {
    guard let urlString,
      let url = URL(string: urlString),
      let (data, _) = try? await URLSession.shared.data(from: url)
    else { return nil }
    return UIImage(data: data)
  }
}
