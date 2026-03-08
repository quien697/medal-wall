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
    bio: "I am here to cross the finish line!",
    gender: .male,
    birthday: DateComponents(calendar: .current, year: 1989, month: 11, day: 23).date!
  )
  
  @MainActor
  static let guest: User = User()
}
