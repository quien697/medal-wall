//
//  UIImage+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2026-05-20.
//

import UIKit

extension UIImage {
  /// Downloads an image from the given URL string and returns it, or nil if loading fails.
  static func load(from urlString: String?) async -> UIImage? {
    guard let urlString,
          let url = URL(string: urlString),
          let (data, _) = try? await URLSession.shared.data(from: url) else { return nil }
    return UIImage(data: data)
  }
}
