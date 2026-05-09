//
//  AppUser.swift
//  MedalWall
//
//  Created by Quien on 2026-04-28.
//

import Foundation
import FirebaseAuth

struct AppUser {
  let uid: String
  let email: String?
  let displayName: String

  init(firebaseUser: FirebaseAuth.User) {
    uid = firebaseUser.uid
    email = firebaseUser.email
    let name = firebaseUser.displayName ?? ""
    displayName = name.isEmpty ? "Runner" : name
  }
}
