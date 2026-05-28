//
//  SignInWithEmailLinkView.swift
//  MedalWall
//
//  Created by Quien on 2026-05-04.
//

import SwiftUI

struct SignInWithEmailLinkView: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss
  // MARK: - Properties
  @Binding var email: String
  let isEmailLinkSent: Bool
  let isEmailValid: Bool
  let isSendingEmail: Bool
  let onSendLink: () async -> Void

  // MARK: - Body
  var body: some View {
    NavigationStack {
      Group {
        if isEmailLinkSent {
          EmailConfirmationSection(
            email: email,
            onDismiss: { dismiss() }
          )
        } else {
          EmailInputSection(
            email: $email,
            isEmailValid: isEmailValid,
            isSendingEmail: isSendingEmail,
            onSendLink: onSendLink
          )
        }
      }  // Group
      .navigationTitle("Continue with Email")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(role: .close) {
            dismiss()
          }
        }
      }  // toolbar
    }  // NavigationStack
  }
}

#Preview("Idel") {
  @Previewable @State var email = ""

  SignInWithEmailLinkView(
    email: $email,
    isEmailLinkSent: false,
    isEmailValid: false,
    isSendingEmail: false,
    onSendLink: {}
  )
}

#Preview("Sending") {
  @Previewable @State var email = "you@example.com"

  SignInWithEmailLinkView(
    email: $email,
    isEmailLinkSent: false,
    isEmailValid: true,
    isSendingEmail: true,
    onSendLink: {}
  )
}

#Preview("Confirmation") {
  @Previewable @State var email = "quien697@gmail.com"

  SignInWithEmailLinkView(
    email: $email,
    isEmailLinkSent: true,
    isEmailValid: true,
    isSendingEmail: false,
    onSendLink: {}
  )
}
