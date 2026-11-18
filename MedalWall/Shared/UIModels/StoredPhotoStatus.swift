//
//  StoredPhotoStatus.swift
//  MedalWall
//
//  Created by Quien on 2026-11-14.
//

/// Where a form's stored photo is while the form downloads it to show.
///
/// A form holds one only while it has a stored photo it is not showing: from opening until the
/// photo arrives, or for good when it cannot be downloaded. Picking or removing a photo ends it.
enum StoredPhotoStatus {
  /// The stored photo is still downloading.
  case loading
  /// The stored photo could not be downloaded; it stays stored unless the user changes it.
  case failed
}
