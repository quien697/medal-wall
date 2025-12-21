//
//  Medal.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation
import UIKit
import SwiftData

@Model
final class Medal {
  @Attribute(.unique) var id: UUID
  var title: String
  var date: Date
  var result: String?
  var photoData: Data?
  var note: String?
  
  @Relationship var user: User
  @Relationship var raceCategory: RaceCategory
  
  init(
    id: UUID = UUID(),
    title: String,
    date: Date,
    result: String? = nil,
    photoData: Data? = nil,
    note: String? = nil,
    user: User,
    raceCategory: RaceCategory
  ) {
    self.id = id
    self.title = title
    self.date = date
    self.result = result
    self.photoData = photoData
    self.note = note
    self.user = user
    self.raceCategory = raceCategory
  }
}


/// Extends Race with computed values
/// Will stay here until v2
extension Medal {
  var photo: UIImage? {
    if let photoData {
      return UIImage(data: photoData)
    }
    
    return nil
  }

}
