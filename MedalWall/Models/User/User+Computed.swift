//
//  User+Computed.swift
//  MedalWall
//
//  Created by Quien on 2026-05-27.
//

extension User {
  var userName: UserName {
    UserName(firstName: firstName ?? "", lastName: lastName ?? "")
  }

  /// Displays firstName lastName with a space. Falls back to "Runner" if both are empty.
  var name: String { userName.fullName }
}
