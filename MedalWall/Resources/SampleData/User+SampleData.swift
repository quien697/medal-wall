//
//  User+SampleData.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

extension User {
  @MainActor
  static let defaultUser: User = User(
    name: UserName(firstName: "Tsung-Hsun", lastName: "Liu"),
    avatar: "tsung-hsun-liu",
    gender: .male
  )
}
