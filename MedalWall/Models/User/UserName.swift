//
//  UserName.swift
//  MedalWall
//
//  Created by Quien on 2025-11-05.
//

struct UserName {
  let firstName: String
  let lastName: String
  
  var fullName: String {
    "\(firstName), \(lastName)"
  }
}
