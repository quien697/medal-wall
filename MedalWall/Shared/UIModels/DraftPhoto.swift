//
//  DraftPhoto.swift
//  MedalWall
//
//  Created by Quien on 2026-11-20.
//

import UIKit

/// A form's photo while it is edited: what its slot shows, the cropped photo save uploads, and
/// whether the user changed it.
struct DraftPhoto {
  /// What the slot shows: the stored photo once downloaded or a cropped one, the stored photo's
  /// status while it isn't shown, or nothing.
  private(set) var content: PhotoSlotContent
  /// The photo cropped this session, or staged in an earlier one, which save uploads; `nil` if
  /// none.
  private(set) var croppedPhoto: CroppedPhoto?
  /// Whether the user cropped or removed a photo since the form opened or last saved.
  private(set) var isChanged = false

  /// A photo whose stored copy at `storedPhotoUrl`, if any, is yet to download, starting from
  /// `staged`, a photo cropped in an earlier session and not yet saved.
  init(storedPhotoUrl: String? = nil, staged: CroppedPhoto? = nil) {
    croppedPhoto = staged
    if let staged {
      content = .photo(staged.image)
    } else {
      content = storedPhotoUrl == nil ? .empty : .loading
    }
  }

  /// Shows a newly cropped photo and stages it for save.
  mutating func update(with photo: CroppedPhoto) {
    content = .photo(photo.image)
    croppedPhoto = photo
    isChanged = true
  }

  /// Removes the photo, so save removes the stored one.
  mutating func remove() {
    content = .empty
    croppedPhoto = nil
    isChanged = true
  }

  /// Shows the stored photo once downloaded. A download that fails marks a loading stored
  /// photo failed and keeps one already shown. A photo the user cropped or removed meanwhile is
  /// kept.
  mutating func showStored(_ downloaded: UIImage?) {
    guard !isChanged else { return }

    if let downloaded {
      content = .photo(downloaded)
    } else if content == .loading {
      content = .failed
    }
  }

  /// Records that save stored this photo, so saving again keeps it rather than uploading it
  /// twice.
  mutating func markSaved() {
    isChanged = false
  }
}
