//
//  User.swift
//  MedalWall
//
//  Created by Quien on 2026-04-28.
//

import FirebaseAuth
import Foundation

struct User: Codable {
  let uid: String
  let email: String?
  var firstName: String?
  var lastName: String?
  var photoUrl: String?
  var bio: String?
  var gender: Gender?
  var birthday: Date?
  let createdAt: Date
  var updatedAt: Date?

  /// Creates a new User from Firebase Auth on first sign-in.
  /// firstName/lastName are seeded separately from the provider via UserDefaults.
  init(firebaseUser: FirebaseAuth.User) {
    uid = firebaseUser.uid
    email = firebaseUser.email
    firstName = nil
    lastName = nil
    photoUrl = nil
    bio = nil
    gender = nil
    birthday = nil
    createdAt = Date()
    updatedAt = nil
  }

  /// Creates a User with explicit field values for use in previews and tests.
  init(
    uid: String,
    email: String?,
    firstName: String? = nil,
    lastName: String? = nil,
    photoUrl: String? = nil,
    bio: String? = nil,
    gender: Gender? = nil,
    birthday: Date? = nil,
    createdAt: Date = .now,
    updatedAt: Date? = nil
  ) {
    self.uid = uid
    self.email = email
    self.firstName = firstName
    self.lastName = lastName
    self.photoUrl = photoUrl
    self.bio = bio
    self.gender = gender
    self.birthday = birthday
    self.createdAt = createdAt
    self.updatedAt = updatedAt
  }
}
