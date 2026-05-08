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
        Text("Send Sign-in Link")
          .frame(maxWidth: .infinity)
      } // Button
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
      .disabled(!isEmailValid)

      Spacer()
    } // VStack
    .padding()
  }
}

#Preview {
  @Previewable @State var email = ""
  EmailInputSection(
    email: $email,
    isEmailValid: false,
    onSendLink: {}
  )
}
