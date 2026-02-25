//
//  UserName.swift
//  MedalWall
//
//  Created by Quien on 2025-11-05.
//

import Foundation

struct UserName {
  var firstName: String
  var lastName: String
  
  nonisolated
  var trimmedFirstName: String {
    firstName.trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  nonisolated
  var trimmedLastName: String {
    lastName.trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  nonisolated
  var fullName: String {
    let parts = [trimmedFirstName, trimmedLastName].filter { !$0.isEmpty }
    let name = parts.joined(separator: ", ")
    return name.isEmpty ? "Runner" : name
  }
}
