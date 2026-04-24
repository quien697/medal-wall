//
//  User+Computed.swift
//  MedalWall
//
//  Created by Quien on 2026-02-24.
//

import UIKit

/// Extends User with computed values
extension User {
  var avatar: UIImage? {
    if let avatarData {
      return UIImage(data: avatarData)
    }
    
    return nil
  }
  
  var genderEnum: Gender? {
    guard let gender = gender else { return nil }
    
    return Gender(rawValue: gender)
  }
  
  var userName: UserName {
    UserName(firstName: firstName, lastName: lastName)
  }
  
  var fullName: String { userName.fullName }
}
