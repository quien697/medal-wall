//
//  ErrorWrapper.swift
//  MedalWall
//
//  Created by Quien on 2025-11-15.
//

import Foundation

/// Gives each presentation of an `AppError` its own identity for `.sheet(item:)`.
///
/// Two failures of the same case are equal errors, but each must still present its
/// own sheet — so identity is minted per presentation rather than derived from the error.
struct ErrorWrapper: Identifiable {
  let id = UUID()
  let error: AppError
}
