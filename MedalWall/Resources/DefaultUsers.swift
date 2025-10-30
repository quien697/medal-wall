//
//  DefaultUsers.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import Foundation
import SwiftData

enum DefaultUsers {
  
  static let demo = User(
    id: UUID(),
    firstName: "Tsung-Hsun",
    lastName: "Liu",
    avatar: nil,
    gender: .male,
    birthdate: nil,
  )
}
