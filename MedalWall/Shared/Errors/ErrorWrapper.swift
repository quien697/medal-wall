//
//  ErrorWrapper.swift
//  MedalWall
//
//  Created by Quien on 2025-11-15.
//

import Foundation

struct ErrorWrapper: Identifiable {
  let id: UUID
  let error: AppError
  
  init(id: UUID = UUID(), error: AppError) {
    self.id = id
    self.error = error
  }
}
