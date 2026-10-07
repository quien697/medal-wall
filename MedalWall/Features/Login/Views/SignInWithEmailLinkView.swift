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

  // MARK: - State
  @State private var errorWrapper: ErrorWrapper?

  // MARK: - Properties
  @Binding var email: String
  /// An error from sending the link, shown over this sheet and reset to nil once closed.
  @Binding var error: AppError?
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
    .sheet(
      item: $errorWrapper,
      onDismiss: { error = nil },
      content: { wrapper in
        ErrorView(errorWrapper: wrapper)
      }
    )
    // `initial`: lets a preview open with an error already set.
    .onChange(of: error, initial: true) { _, newError in
      if let newError {
        errorWrapper = ErrorWrapper(error: newError)
      }
    }
  }
}

#Preview("Idle") {
  @Previewable @State var email = ""

  SignInWithEmailLinkView(
    email: $email,
    error: .constant(nil),
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
    error: .constant(nil),
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
    error: .constant(nil),
    isEmailLinkSent: true,
    isEmailValid: true,
    isSendingEmail: false,
    onSendLink: {}
  )
}

#Preview("Send failed") {
  @Previewable @State var email = "you@example.com"
  @Previewable @State var error: AppError? = .noInternetConnection

  SignInWithEmailLinkView(
    email: $email,
    error: $error,
    isEmailLinkSent: false,
    isEmailValid: true,
    isSendingEmail: false,
    onSendLink: {}
  )
}
