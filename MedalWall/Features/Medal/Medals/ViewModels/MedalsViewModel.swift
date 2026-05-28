//
//  MedalsViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-04-03.
//

import SwiftUI

@Observable
final class MedalsViewModel {
  // MARK: - Data
  var medals: [Medal] = []

  // MARK: - State
  var isLoading = false
  var error: AppError?

  // MARK: - Dependencies
  private let repository = MedalFirestoreRepository()

  // MARK: - Computed
  var totalCount: Int { medals.count }
  var fullCount: Int { medals.fullCount }
  var halfCount: Int { medals.halfCount }

  let gridSpacing: CGFloat = 16

  var gridColumns: [GridItem] {
    [GridItem](
      repeating: GridItem(.flexible(minimum: 80), spacing: gridSpacing),
      count: 2
    )
  }

  // MARK: - Functions

  /// Loads all medals for the given user from Firestore.
  func loadMedals(userId: String) async {
    defer { isLoading = false }
    isLoading = true
    do {
      medals = try await repository.fetchMedals(userId: userId)
    } catch {
      self.error = .medalFetchFailed(error.localizedDescription)
    }
  }
}
