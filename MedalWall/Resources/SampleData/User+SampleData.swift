//
//  User+SampleData.swift
//  MedalWall
//
//  Created by Quien on 2026-05-27.
//

import Foundation

extension User {
  static let preview = User(
    uid: "preview",
    email: "preview@example.com",
    firstName: "John",
    lastName: "Doe"
  )
}

extension User {
  /// Stands in for the profile while it first loads, behind a skeleton: a 14-character name
  /// and a one-line bio, so the bones read like a real header.
  static let placeholder = User(
    uid: "placeholder",
    email: nil,
    firstName: "Alexander",
    lastName: "Chen",
    bio: "One finish line at a time."
  )
}
