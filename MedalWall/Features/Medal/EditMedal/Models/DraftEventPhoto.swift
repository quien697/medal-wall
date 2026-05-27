//
//  DraftEventPhoto.swift
//  MedalWall
//
//  Created by Quien on 2026-04-18.
//

import Foundation
import UIKit

struct DraftEventPhoto: Identifiable {
  let id: String
  var imageUrl: String?
  var data: Data?

  var isNew: Bool { data != nil }
  var image: UIImage? { data.flatMap { UIImage(data: $0) } }

  init(id: String = UUID().uuidString, imageUrl: String) {
    self.id = id
    self.imageUrl = imageUrl
  }

  init(id: String = UUID().uuidString, data: Data) {
    self.id = id
    self.data = data
  }
}
