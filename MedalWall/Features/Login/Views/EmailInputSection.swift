//
//  EmailInputSection.swift
//  MedalWall
//
//  Created by Quien on 2026-05-08.
//

import SwiftUI

struct EmailInputSection: View {
  // MARK: - Properties
  @Binding var email: String
  let isEmailValid: Bool
  let isSendingEmail: Bool
  let onSendLink: () async -> Void

  // MARK: - Body
  var body: some View {
    VStack(alignment: .center, spacing: 16) {
      EmailSignInHeader(
        title: "What's your email?",
        subTitle: "Enter your email address and we'll send you a sign-in link. No password needed."
      )

      TextField("you@example.com", text: $email)
        .keyboardType(.emailAddress)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .padding()
        .background(Color.Card.Background.tertiary)
        .clipShape(.rect(cornerRadius: 12))
        .tint(Color.Text.primary)

      Button {
        Task {
          await onSendLink()
        }
      } label: {
        Group {
          if isSendingEmail {
            ProgressView()
              .tint(.white)
          } else {
            Text("Send Sign-in Link")
          }
        }  // Group
        .frame(maxWidth: .infinity)
      }  // Button
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
      .disabled(!isEmailValid || isSendingEmail)

      Spacer()
    }  // VStack
    .padding()
  }
}

#Preview("Idle") {
  @Previewable @State var email = ""

  EmailInputSection(
    email: $email,
    isEmailValid: false,
    isSendingEmail: false,
    onSendLink: {}
  )
}

#Preview("Email Valid") {
  @Previewable @State var email = "you@example.com"

  EmailInputSection(
    email: $email,
    isEmailValid: true,
    isSendingEmail: false,
    onSendLink: {}
  )
}

#Preview("Sending") {
  @Previewable @State var email = "you@example.com"

  EmailInputSection(
    email: $email,
    isEmailValid: true,
    isSendingEmail: true,
    onSendLink: {}
  )
}
