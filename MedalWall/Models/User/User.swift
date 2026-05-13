//
//  User.swift
//  MedalWall
//
//  Created by Quien on 2026-04-28.
//

import Foundation
import FirebaseAuth

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
}

extension User {
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
  
  var userName: UserName {
    UserName(firstName: firstName ?? "", lastName: lastName ?? "")
  }
  
  /// Displays firstName lastName with a space. Falls back to "Runner" if both are empty.
  var name: String { userName.fullName }
}
