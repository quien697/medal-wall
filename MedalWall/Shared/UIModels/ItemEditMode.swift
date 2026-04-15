//
//  ItemEditMode.swift
//  MedalWall
//
//  Created by Quien on 2026-04-15.
//

enum ItemEditMode {
  case add, edit
  
  var displayName: String {
    switch self {
    case .add: return "New"
    case .edit: return "Edit"
    }
  }
}
