//
//  User+SampleData.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import UIKit

extension User {
  @MainActor
  static let defaultUser: User = User(
    name: UserName(firstName: "Tsung-Hsun", lastName: "Liu"),
    avatarData: UIImage(named: "quien")?.jpegData(compressionQuality: 0.9),
    bio: "Fake it till make it!",
    gender: .male,
    birthday: .now
  )
}
