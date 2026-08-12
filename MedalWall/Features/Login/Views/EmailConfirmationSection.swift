//
//  EmailConfirmationSection.swift
//  MedalWall
//
//  Created by Quien on 2026-05-08.
//

import SwiftUI

struct EmailConfirmationSection: View {
  // MARK: - Properties
  let email: String
  let onDismiss: () -> Void

  // MARK: - Body
  var body: some View {
    VStack(alignment: .center, spacing: 16) {
      EmailSignInHeader(
        title: "Now check your email",
        subTitle: """
          We sent To \(email).
          To complete sign-in, tap the sign-in link in your email, \
          if it doesn't arrive within 3 minutes, check your spam folder
          """
      )

      Button {
        onDismiss()
      } label: {
        Text("Close")
          .frame(maxWidth: .infinity)
      }  // Button
      .buttonStyle(.borderedProminent)
      .controlSize(.large)

      Spacer()
    }  // VStack
    .padding()
  }
}

#Preview {
  EmailConfirmationSection(
    email: "quien697@gmail.com",
    onDismiss: {}
  )
}
