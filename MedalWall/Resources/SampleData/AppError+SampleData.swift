//
//  AppError+SampleData.swift
//  MedalWall
//
//  Created by Quien on 2026-09-17.
//

import Foundation

extension AppError {
  /// One error from every family, plus both extremes of the copy — the longest message
  /// (a server description interpolated into it) and the shortest — so a preview gallery
  /// shows what the sheet has to hold at either end.
  static let sampleData: [AppError] = [
    .raceFetchFailed("Missing or insufficient permissions."),
    .medalSaveFailed,
    .editionDeleteFailed,
    .notSignedIn,
    .duplicateDistance,
    .invalidDistance,
    .photoDataInvalid,
    .placeNotResolved,
    .sendEmailSignInLinkFailed("The email address is badly formatted."),
    .noInternetConnection,
    .signInFailed,
    .unknown
  ]
}
