//
//  Alert+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2025-11-30.
//

import SwiftUI

/// Shared alerts, so a destructive prompt reads the same wherever it is raised.
extension Alert {

  /// A two-button confirmation for deleting what `prompt` names, with Delete destructive
  /// and Cancel alongside it.
  ///
  /// `DeletePrompt` owns both lines: a call site picks the case, never the wording.
  static func deleteConfirmation(
    _ prompt: DeletePrompt,
    onDelete: @escaping () -> Void
  ) -> Alert {
    Alert(
      title: Text(prompt.title),
      message: Text(prompt.message),
      primaryButton: .destructive(Text("Delete"), action: onDelete),
      secondaryButton: .cancel()
    )
  }
}
