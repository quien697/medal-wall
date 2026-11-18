//
//  PickedPhoto.swift
//  MedalWall
//
//  Created by Quien on 2026-11-13.
//

import UIKit

/// A photo picked or taken, waiting to be cropped, with its own identity for `.sheet(item:)`.
///
/// The crop sheet is presented from this rather than from a flag beside the photo: a sheet's
/// content reading `@State` its view's body never reads gets the value from before the first
/// presentation, so the first crop screen would open without the photo.
struct PickedPhoto: Identifiable {
  let id = UUID()
  let image: UIImage
}
