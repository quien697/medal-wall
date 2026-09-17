//
//  AppTheme.swift
//  MedalWall
//
//  Created by Quien on 2026-04-20.
//

import SwiftUI

nonisolated enum AppTheme: String, CaseIterable {
  case system, light, dark

  var label: String {
    switch self {
    case .system: .appLocalized("System")
    case .light: .appLocalized("Light")
    case .dark: .appLocalized("Dark")
    }
  }

  var icon: String {
    switch self {
    case .system: "circle.lefthalf.filled"
    case .light: "sun.max"
    case .dark: "moon"
    }
  }

  var colorScheme: ColorScheme? {
    switch self {
    case .system: nil
    case .light: .light
    case .dark: .dark
    }
  }
}
