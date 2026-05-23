//
//  AppError.swift
//  MedalWall
//
//  Created by Quien on 2025-11-28.
//

import Foundation

enum AppError: LocalizedError, Identifiable, Equatable {
  // Auth, Login Errors
  case invalidCredential
  case missingNonce
  case missingIdentityToken
  case nonceFailed(String)
  case tokenSerializationFailed(String)
  case signInFailed
  case noInternetConnection
  case sendEmailSignInLinkFailed(String)
  
  // Repository / Persistence Errors
  case contextNotAttached
  case raceFetchFailed(String)
  case raceSaveFailed
  case raceDeleteFailed
  case editionSaveFailed
  case editionDeleteFailed
  case userSaveFailed
  
  // User Manager
  case userLoadFailed
  
  // Validation Errors
  case duplicateEdition
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
    case .raceFetchFailed:
      "Failed to Load Races"
    case .raceSaveFailed:
      "Race Save Failed"
    case .raceDeleteFailed:
      "Race Delete Failed"
    case .editionSaveFailed:
      "Edition Save Failed"
    case .editionDeleteFailed:
      "Edition Delete Failed"
    case .userSaveFailed:
      "User Save Failed"
    case .userLoadFailed:
      "User Load Failed"
    case .duplicateEdition:
      "Duplicate Edition"
    case .duplicateDistance:
      "Duplicate Distance"
    case .photoLoadFailed:
      "Photo Load Failed"
    case .photoDataInvalid:
      "Photo Data Invalid"
    case .sendEmailSignInLinkFailed:
      "Send Email Sign-in Link Failed"
    case .noInternetConnection:
      "No Internet Connection"
    case .invalidCredential,
        .missingNonce,
        .missingIdentityToken,
        .nonceFailed(_),
        .tokenSerializationFailed(_),
        .signInFailed:
      "Sign In Failed"
    case .unknown:
      "Unexpected Error"
    }
  }
  
  var message: String {
    switch self {
    case .contextNotAttached:
      "Internal error: Data context not available."
    case .raceFetchFailed(let description):
      "We couldn't load your races. \(description)"
    case .raceSaveFailed:
      "We couldn't save your race event."
    case .raceDeleteFailed:
      "We couldn't delete this race event. Please try again."
    case .editionSaveFailed:
      "We couldn't save this edition."
    case .editionDeleteFailed:
      "We couldn't delete this edition. Please try again."
    case .userSaveFailed:
      "We couldn't save your user information."
    case .userLoadFailed:
      "We couldn't load your user profile."
    case .duplicateEdition:
      "An edition with the same year already exists."
    case .duplicateDistance:
      "This distance already exists."
    case .photoLoadFailed:
      "We couldn't load this photo."
    case .photoDataInvalid:
      "We couldn't process the selected image."
    case .invalidCredential:
      "Failed to get Apple ID credential."
    case .missingNonce:
      "Sign-in session expired."
    case .missingIdentityToken:
      "Failed to fetch identity token from Apple."
    case .nonceFailed(let status):
      "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(status)."
    case .tokenSerializationFailed(let description):
      "Failed to serialize token string from data: \(description)."
    case .sendEmailSignInLinkFailed(let description):
      "We couldn't send the sign-in link to your email. \(description)"
    case .noInternetConnection:
      "You're not connected to the internet."
    case .signInFailed:
      "We couldn't sign you in."
    case .unknown:
      "Something unexpected happened."
    }
  }
  
  var guidance: String {
    switch self {
    case .contextNotAttached:
      "Please restart the app. If the problem continues, contact support."
    case .raceFetchFailed:
      "Please check your connection and try again."
    case .raceSaveFailed, .raceDeleteFailed, .editionSaveFailed, .editionDeleteFailed, .userSaveFailed:
      "Please try it again."
    case .userLoadFailed:
      "Please restart the app. If the problem continues, you may need to reinstall."
    case .duplicateEdition:
      "Please choose a different year or edit the existing edition."
    case .duplicateDistance:
      "Please try selecting a different distance or type."
    case .photoLoadFailed:
      "Please try selecting the image again."
    case .photoDataInvalid:
      "Please try choosing a different image."
    case .sendEmailSignInLinkFailed:
      "Please check your email address and try again."
    case .noInternetConnection:
      "Please check your connection and try again."
    case .invalidCredential,
        .missingNonce,
        .missingIdentityToken,
        .nonceFailed(_),
        .tokenSerializationFailed(_),
        .signInFailed:
      "Please try signing in again."
    case .unknown:
      "Please try again later."
    }
  }
}
