//
//  UserName.swift
//  MedalWall
//
//  Created by Quien on 2025-11-05.
//

struct UserName {
  var firstName: String
  var lastName: String
  
  var fullName: String {
    "\(firstName), \(lastName)"
  }
}
