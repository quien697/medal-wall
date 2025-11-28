//
//  AppError.swift
//  MedalWall
//
//  Created by Quien on 2025-11-28.
//

import Foundation

enum AppError: LocalizedError, Identifiable {
  case raceSaveFailed
  case raceDeleteFailed
  case duplicateDistance
  case photoLoadFailed
  case photoDataInvalid
  case unknown
  
  var id: String { localizedDescription }
  
  var title: String {
    switch self {
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
    case .raceSaveFailed:
      "We couldn't save your race event. Please check your info and try again."
    case .raceDeleteFailed:
      "We couldn't delete this race event. Please try again."
    case .duplicateDistance:
      "This distance is already added. Please choose a different category or type."
    case .photoLoadFailed:
      "We couldn't load this photo. Please choose another image."
    case .photoDataInvalid:
      "We couldn't load the required data. Please try again later."
    case .unknown:
      "Something went wrong. Please try again."
    }
  }
  
  func alwaysThrowsError() throws {
    
  }
}
