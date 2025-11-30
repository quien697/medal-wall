//
//  AppError.swift
//  MedalWall
//
//  Created by Quien on 2025-11-28.
//

import Foundation

enum AppError: LocalizedError, Identifiable {
  // Repository / Persistence Errors
  case contextNotAttached
  case raceSaveFailed
  case raceDeleteFailed
  
  // Validation Errors
  case duplicateDistance
  
  // Media Errors
  case photoLoadFailed
  case photoDataInvalid
  
  // Unknown
  case unknown
  
  var id: String { localizedDescription }
  
  var title: String {
    switch self {
    case .contextNotAttached:
      "Context hasn't attached yet"
    case .raceSaveFailed:
      "Save Failed"
    case .raceDeleteFailed:
      "Delete Failed"
    case .duplicateDistance:
      "Duplicate Distance"
    case .photoLoadFailed:
      "Photo Load Failed"
    case .photoDataInvalid:
      "Photo Data Invalid"
    case .unknown:
      "Unexpected Error"
    }
  }
  
  var message: String {
    switch self {
    case .contextNotAttached:
      "Internal error: Data context not available."
    case .raceSaveFailed:
      "We couldn't save your race event."
    case .raceDeleteFailed:
      "We couldn't delete this race event. Please try again."
    case .duplicateDistance:
      "This distance already exists."
    case .photoLoadFailed:
      "We couldn't load this photo."
    case .photoDataInvalid:
      "We couldn't process the selected image."
    case .unknown:
      "Something unexpected happened."
    }
  }
  
  var guidance: String {
    switch self {
    case .contextNotAttached:
      "Please restart the app. If the problem continues, contact support."
    case .raceSaveFailed, .raceDeleteFailed:
      "Please try it again."
    case .duplicateDistance:
      "Please try selecting a different distance or type."
    case .photoLoadFailed:
      "Please try selecting the image again."
    case .photoDataInvalid:
      "Please try choosing a different image."
    case .unknown:
      "Please try again later."
    }
  }
}
