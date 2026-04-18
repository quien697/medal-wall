//
//  DraftEventPhoto.swift
//  MedalWall
//
//  Created by Quien on 2026-04-18.
//

import Foundation
import UIKit

struct DraftEventPhoto: Identifiable {
  let id: UUID = UUID()
  let data: Data

  var image: UIImage? {
    UIImage(data: data)
  }
}
