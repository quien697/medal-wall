//
//  UIImage+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2026-05-20.
//

import UIKit

/// Loading and encoding for photos the user edits, as distinct from photos the app displays.
extension UIImage {

  /// The size, in bytes, that every upload must stay under: the cap `storage.rules` sets.
  nonisolated static let maxUploadByteCount = 10 * 1024 * 1024

  /// JPEG bytes at the app's upload quality and the image's own pixel size, or nil if the
  /// image cannot be encoded.
  ///
  /// The one place that quality is chosen: `StorageService` uploads these bytes, and Edit
  /// ViewModels stage them on a draft before save. Nonisolated so a picked photo can be
  /// encoded off the main actor.
  nonisolated func uploadData() -> Data? {
    jpegData(compressionQuality: 0.8)
  }

  /// The JPEG to upload, from `uploadData()`. Throws `.photoDataInvalid` if the image cannot
  /// be encoded, and `.photoTooLarge` if Storage would refuse the JPEG's size.
  nonisolated func checkedUploadData() throws -> Data {
    guard let data = uploadData() else { throw AppError.photoDataInvalid }
    return try Self.checkedUploadSize(data)
  }

  /// Returns `data` if it is under `maxUploadByteCount`, and otherwise throws
  /// `.photoTooLarge`.
  nonisolated static func checkedUploadSize(_ data: Data) throws -> Data {
    guard data.count < maxUploadByteCount else { throw AppError.photoTooLarge }
    return data
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
