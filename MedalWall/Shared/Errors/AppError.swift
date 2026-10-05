//
//  AppError.swift
//  MedalWall
//
//  Created by Quien on 2025-11-28.
//

import Foundation

/// Every failure the app shows a user, thrown from repositories and ViewModels and
/// presented by `ErrorView` as a title, a message, and guidance on what to do next.
///
/// A `String` payload carries the underlying error's description and is interpolated
/// into `message` untranslated.
nonisolated enum AppError: LocalizedError, Equatable {
  // Auth, Login Errors
  case invalidCredential
  case missingIdentityToken
  case nonceFailed(String)
  case tokenSerializationFailed(String)
  case signInFailed
  case noInternetConnection
  case sendEmailSignInLinkFailed(String)
  case emailLinkSignInFailed
  case emailLinkFromAnotherDevice

  // Repository / Persistence Errors
  case raceFetchFailed(String)
  case raceSaveFailed
  case raceDeleteFailed
  case editionSaveFailed
  case editionDeleteFailed
  case medalFetchFailed(String)
  case medalSaveFailed
  case medalDeleteFailed
  case userSaveFailed

  // User Manager
  case notSignedIn

  // Validation Errors
  case duplicateDistance
  case invalidDistance

  // Media Errors
  case photoDataInvalid

  // Place Errors
  case placeSearchFailed(String)
  case placeNotResolved

  // Unknown
  case unknown

  /// Lets code that only sees `any Error` read `message` through `localizedDescription`.
  var errorDescription: String? { message }

  /// Exposes `guidance` to code that only sees `LocalizedError`.
  var recoverySuggestion: String? { guidance }

  /// A short heading naming what failed.
  var title: String {
    switch self {
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
    case .userSaveFailed:
      .appLocalized("User Save Failed")
    case .notSignedIn:
      .appLocalized("Not Signed In")
    case .duplicateDistance:
      .appLocalized("Duplicate Distance")
    case .invalidDistance:
      .appLocalized("Invalid Distance")
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
      .missingIdentityToken,
      .nonceFailed,
      .tokenSerializationFailed,
      .signInFailed,
      .emailLinkSignInFailed,
      .emailLinkFromAnotherDevice:
      .appLocalized("Sign In Failed")
    case .unknown:
      .appLocalized("Unexpected Error")
    }
  }

  /// A sentence explaining what went wrong.
  var message: String {
    switch self {
    case .raceFetchFailed(let description):
      .appLocalized("We couldn't load your races. \(description)")
    case .raceSaveFailed:
      .appLocalized("We couldn't save your race event.")
    case .raceDeleteFailed:
      .appLocalized("We couldn't delete this race event.")
    case .editionSaveFailed:
      .appLocalized("We couldn't save this edition.")
    case .editionDeleteFailed:
      .appLocalized("We couldn't delete this edition.")
    case .medalFetchFailed(let description):
      .appLocalized("We couldn't load your medals. \(description)")
    case .medalSaveFailed:
      .appLocalized("We couldn't save this medal.")
    case .medalDeleteFailed:
      .appLocalized("We couldn't delete this medal.")
    case .userSaveFailed:
      .appLocalized("We couldn't save your user information.")
    case .notSignedIn:
      .appLocalized("You're not signed in.")
    case .duplicateDistance:
      .appLocalized("This distance already exists.")
    case .invalidDistance:
      .appLocalized("Distance must be greater than zero.")
    case .photoDataInvalid:
      .appLocalized("We couldn't process the selected image.")
    case .placeSearchFailed(let description):
      .appLocalized("We couldn't search for places. \(description)")
    case .placeNotResolved:
      .appLocalized("We couldn't get the details for that place.")
    case .invalidCredential:
      .appLocalized("Failed to get Apple ID credential.")
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
    case .emailLinkSignInFailed:
      .appLocalized("We couldn't sign you in with this link.")
    case .emailLinkFromAnotherDevice:
      .appLocalized("This sign-in link wasn't requested on this device.")
    case .unknown:
      .appLocalized("Something unexpected happened.")
    }
  }

  /// What the user can do next.
  var guidance: String {
    switch self {
    case .raceFetchFailed, .medalFetchFailed, .placeSearchFailed, .placeNotResolved,
      .noInternetConnection:
      .appLocalized("Please check your connection and try again.")
    case .raceSaveFailed, .raceDeleteFailed, .editionSaveFailed, .editionDeleteFailed,
      .medalSaveFailed, .medalDeleteFailed, .userSaveFailed:
      .appLocalized("Please try it again.")
    case .notSignedIn:
      .appLocalized("Please sign in and try again.")
    case .duplicateDistance:
      .appLocalized("Please try selecting a different distance or type.")
    case .invalidDistance:
      .appLocalized("Please enter a distance greater than 0.")
    case .photoDataInvalid:
      .appLocalized("Please try choosing a different image.")
    case .sendEmailSignInLinkFailed:
      .appLocalized("Please check your email address and try again.")
    case .emailLinkSignInFailed:
      .appLocalized("Please check your connection, or request a new link.")
    case .emailLinkFromAnotherDevice:
      .appLocalized("Please request a new link on this device.")
    case .invalidCredential,
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
