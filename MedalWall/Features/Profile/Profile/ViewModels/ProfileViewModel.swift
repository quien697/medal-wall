//
//  ProfileViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-04-18.
//

import SwiftUI

@Observable
final class ProfileViewModel {
  // MARK: - Data
  var medals: [Medal] = []

  // MARK: - Dependencies
  private let emptyWithDash: String = "-"
  private let repository = MedalFirestoreRepository()

  // MARK: - Functions

  /// Loads all medals for the given user from Firestore.
  func loadMedals(userId: String) async {
    medals = (try? await repository.fetchMedals(userId: userId)) ?? []
  }

  func totalMedals(_ medals: [Medal]) -> Int {
    medals.count
  }

  func fullCount(_ medals: [Medal]) -> Int {
    medals.filter { $0.distance.category == .full }.count
  }

  func halfCount(_ medals: [Medal]) -> Int {
    medals.filter { $0.distance.category == .half }.count
  }

  func bestFullTime(_ medals: [Medal]) -> String {
    medals
      .filter { $0.distance.category == .full }
      .compactMap { $0.finishTime }
      .min()
      .map { $0.formattedHMS } ?? emptyWithDash
  }

  func bestHalfTime(_ medals: [Medal]) -> String {
    medals
      .filter { $0.distance.category == .half }
      .compactMap { $0.finishTime }
      .min()
      .map { $0.formattedHMS } ?? emptyWithDash
  }
}
