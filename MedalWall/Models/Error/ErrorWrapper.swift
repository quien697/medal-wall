//
//  ErrorWrapper.swift
//  MedalWall
//
//  Created by Quien on 2025-11-15.
//

import Foundation

struct ErrorWrapper: Identifiable {
  let id: UUID
  let error: Error
  let guidance: String
  
  init(id: UUID = UUID(), error: Error, guidance: String) {
    self.id = id
    self.error = error
    self.guidance = guidance
  }
}
