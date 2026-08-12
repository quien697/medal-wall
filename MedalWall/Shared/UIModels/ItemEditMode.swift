//
//  ItemEditMode.swift
//  MedalWall
//
//  Created by Quien on 2026-04-15.
//

import Foundation

nonisolated enum ItemEditMode {
  case add, edit

  var displayName: String {
    switch self {
    case .add: return .appLocalized("New")
    case .edit: return .appLocalized("Edit")
    }
  }
}
