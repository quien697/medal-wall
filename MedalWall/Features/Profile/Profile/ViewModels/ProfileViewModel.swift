//
//  ProfileViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-04-18.
//

import SwiftUI

@Observable
final class ProfileViewModel {
  private let emptyWithDash: String = "-"

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
