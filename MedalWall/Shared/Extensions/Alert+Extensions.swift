//
//  Alert+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2025-11-30.
//

import SwiftUI

extension Alert {
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
