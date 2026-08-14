//
//  AppError.swift
//  MedalWall
//
//  Created by Quien on 2025-11-28.
//

import Foundation

nonisolated enum AppError: LocalizedError, Identifiable, Equatable {
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
  case medalFetchFailed(String)
  case medalSaveFailed
  case medalDeleteFailed
  case eventPhotoSaveFailed
  case eventPhotoDeleteFailed
  case userSaveFailed

  // User Manager
  case userLoadFailed

  // Validation Errors
  case duplicateEdition
  case duplicateDistance
  case invalidDistance

  // Media Errors
  case photoLoadFailed
  case photoDataInvalid

  // Place Errors
  case placeSearchFailed(String)
  case placeNotResolved

  // Unknown
  case unknown

  var id: String { localizedDescription }

  var title: String {
    switch self {
    case .contextNotAttached:
      .appLocalized("Context hasn't attached yet")
    case .raceFetchFailed:
      .appLocalized("Failed to Load Races")
    case .raceSaveFailed:
      .appLocalized("Race Save Failed")
    case .raceDeleteFailed:
      .appLocalized("Race Delete Failed")
    case .editionSaveFailed:
      .appLocalized("Edition Save Failed")
    case .editionDeleteFailed:
      .appLocalized("Edition Delete Failed")
    case .medalFetchFailed:
      .appLocalized("Failed to Load Medals")
    case .medalSaveFailed:
      .appLocalized("Medal Save Failed")
    case .medalDeleteFailed:
      .appLocalized("Medal Delete Failed")
    case .eventPhotoSaveFailed:
      .appLocalized("Photo Save Failed")
    case .eventPhotoDeleteFailed:
      .appLocalized("Photo Delete Failed")
    case .userSaveFailed:
      .appLocalized("User Save Failed")
    case .userLoadFailed:
      .appLocalized("User Load Failed")
    case .duplicateEdition:
      .appLocalized("Duplicate Edition")
    case .duplicateDistance:
      .appLocalized("Duplicate Distance")
    case .invalidDistance:
      .appLocalized("Invalid Distance")
    case .photoLoadFailed:
      .appLocalized("Photo Load Failed")
    case .photoDataInvalid:
      .appLocalized("Photo Data Invalid")
    case .placeSearchFailed:
      .appLocalized("Place Search Failed")
    case .placeNotResolved:
      .appLocalized("Place Unavailable")
    case .sendEmailSignInLinkFailed:
      .appLocalized("Send Email Sign-in Link Failed")
    case .noInternetConnection:
      .appLocalized("No Internet Connection")
    case .invalidCredential,
      .missingNonce,
      .missingIdentityToken,
      .nonceFailed,
      .tokenSerializationFailed,
      .signInFailed:
      .appLocalized("Sign In Failed")
    case .unknown:
      .appLocalized("Unexpected Error")
    }
  }

  var message: String {
    switch self {
    case .contextNotAttached:
      .appLocalized("Internal error: Data context not available.")
    case .raceFetchFailed(let description):
      .appLocalized("We couldn't load your races. \(description)")
    case .raceSaveFailed:
      .appLocalized("We couldn't save your race event.")
    case .raceDeleteFailed:
      .appLocalized("We couldn't delete this race event. Please try again.")
    case .editionSaveFailed:
      .appLocalized("We couldn't save this edition.")
    case .editionDeleteFailed:
      .appLocalized("We couldn't delete this edition. Please try again.")
    case .medalFetchFailed(let description):
      .appLocalized("We couldn't load your medals. \(description)")
    case .medalSaveFailed:
      .appLocalized("We couldn't save this medal.")
    case .medalDeleteFailed:
      .appLocalized("We couldn't delete this medal. Please try again.")
    case .eventPhotoSaveFailed:
      .appLocalized("We couldn't save this photo.")
    case .eventPhotoDeleteFailed:
      .appLocalized("We couldn't delete this photo. Please try again.")
    case .userSaveFailed:
      .appLocalized("We couldn't save your user information.")
    case .userLoadFailed:
      .appLocalized("We couldn't load your user profile.")
    case .duplicateEdition:
      .appLocalized("An edition with the same year already exists.")
    case .duplicateDistance:
      .appLocalized("This distance already exists.")
    case .invalidDistance:
      .appLocalized("Distance must be greater than zero.")
    case .photoLoadFailed:
      .appLocalized("We couldn't load this photo.")
    case .photoDataInvalid:
      .appLocalized("We couldn't process the selected image.")
    case .placeSearchFailed(let description):
      .appLocalized("We couldn't search for places. \(description)")
    case .placeNotResolved:
      .appLocalized("We couldn't get the details for that place.")
    case .invalidCredential:
      .appLocalized("Failed to get Apple ID credential.")
    case .missingNonce:
      .appLocalized("Sign-in session expired.")
    case .missingIdentityToken:
      .appLocalized("Failed to fetch identity token from Apple.")
    case .nonceFailed(let status):
      .appLocalized("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(status).")
    case .tokenSerializationFailed(let description):
      .appLocalized("Failed to serialize token string from data: \(description).")
    case .sendEmailSignInLinkFailed(let description):
      .appLocalized("We couldn't send the sign-in link to your email. \(description)")
    case .noInternetConnection:
      .appLocalized("You're not connected to the internet.")
    case .signInFailed:
      .appLocalized("We couldn't sign you in.")
    case .unknown:
      .appLocalized("Something unexpected happened.")
    }
  }

  var guidance: String {
    switch self {
    case .contextNotAttached:
      .appLocalized("Please restart the app. If the problem continues, contact support.")
    case .raceFetchFailed, .medalFetchFailed:
      .appLocalized("Please check your connection and try again.")
    case .raceSaveFailed, .raceDeleteFailed, .editionSaveFailed, .editionDeleteFailed,
      .medalSaveFailed, .medalDeleteFailed, .eventPhotoSaveFailed, .eventPhotoDeleteFailed,
      .userSaveFailed:
      .appLocalized("Please try it again.")
    case .userLoadFailed:
      .appLocalized("Please restart the app. If the problem continues, you may need to reinstall.")
    case .duplicateEdition:
      .appLocalized("Please choose a different year or edit the existing edition.")
    case .duplicateDistance:
      .appLocalized("Please try selecting a different distance or type.")
    case .invalidDistance:
      .appLocalized("Please enter a distance greater than 0.")
    case .photoLoadFailed:
      .appLocalized("Please try selecting the image again.")
    case .photoDataInvalid:
      .appLocalized("Please try choosing a different image.")
    case .placeSearchFailed, .placeNotResolved:
      .appLocalized("Please check your connection and try again.")
    case .sendEmailSignInLinkFailed:
      .appLocalized("Please check your email address and try again.")
    case .noInternetConnection:
      .appLocalized("Please check your connection and try again.")
    case .invalidCredential,
      .missingNonce,
      .missingIdentityToken,
      .nonceFailed,
      .tokenSerializationFailed,
      .signInFailed:
      .appLocalized("Please try signing in again.")
    case .unknown:
      .appLocalized("Please try again later.")
    }
  }
}
