//
//  CroppedPhoto.swift
//  MedalWall
//
//  Created by Quien on 2026-11-19.
//

import UIKit

/// A photo cropped in a `PhotoSlot` and checked against Storage's size cap: the image the slot
/// shows, and the JPEG that save uploads as it is. The photo is encoded once, so the bytes
/// uploaded are the bytes checked.
nonisolated struct CroppedPhoto {
  let image: UIImage
  let jpegData: Data

  /// Encodes `image` as the JPEG to upload. Throws `.photoDataInvalid` if it cannot be
  /// encoded, and `.photoTooLarge` if Storage would refuse the JPEG's size.
  init(checking image: UIImage) throws(AppError) {
    self.image = image
    self.jpegData = try image.checkedUploadData()
  }
}
