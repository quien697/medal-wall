//
//  EventPhoto.swift
//  MedalWall
//
//  Created by Quien on 2026-04-01.
//

import Foundation
import UIKit
import SwiftData

@Model
final class EventPhoto {
  @Attribute(.unique) var id: UUID
  var imageData: Data
  var caption: String?
  var sortOrder: Int

  @Relationship var medal: Medal

  init(
    id: UUID = UUID(),
    imageData: Data,
    caption: String? = nil,
    sortOrder: Int = 0,
    medal: Medal
  ) {
    self.id = id
    self.imageData = imageData
    self.caption = caption
    self.sortOrder = sortOrder
    self.medal = medal
  }
}
