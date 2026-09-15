//
//  Alert+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2025-11-30.
//

import SwiftUI

/// Shared alerts, so a destructive prompt reads the same wherever it is raised.
extension Alert {

  /// A two-button confirmation for deleting `name`, with Delete destructive and Cancel
  /// alongside it.
  ///
  /// `name` is interpolated into the `Delete %@` catalog key, and interpolation localizes
  /// the key rather than the value it receives. So pass either user data — a race or medal
  /// name, which should never be translated — or a string already resolved through
  /// `String.appLocalized`. A bare literal such as `"Edition"` would reach the Chinese
  /// build untranslated, and nothing would flag it.
  static func deleteConfirmation(
    name: String,
    onDelete: @escaping () -> Void
  ) -> Alert {
    Alert(
      title: Text("Delete \(name)"),
      primaryButton: .destructive(Text("Delete"), action: onDelete),
      secondaryButton: .cancel()
    )
  }
}
