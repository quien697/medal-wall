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
  let isLoading: Bool
  let isEmailLinkSent: Bool
  let isEmailValid: Bool
  let onSendLink: () async -> Void

  // MARK: - Body
  var body: some View {
    NavigationStack {
      Group {
        if isEmailLinkSent {
          confirmationView
        } else {
          emailInputView
        }
      } // Group
      .navigationTitle("Sign in with Email Link")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(role: .close) {
            dismiss()
          }
        }
      } // toolbar
    } // NavigationStack
  }

  // MARK: - Email Input
  private var emailInputView: some View {
    VStack(alignment: .leading, spacing: 16) {
      Text("Enter your email address and we'll send you a sign-in link. No password needed.")
        .font(.subheadline)
        .foregroundStyle(.secondary)

      TextField("you@example.com", text: $email)
        .keyboardType(.emailAddress)
        .textInputAutocapitalization(.never)
        .autocorrectionDisabled()
        .padding()
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))

      Spacer()

      Button {
        Task { await onSendLink() }
      } label: {
        Group {
          if isLoading {
            ProgressView()
          } else {
            Text("Send Link")
          }
        } // Group
        .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
      .disabled(!isEmailValid || isLoading)
    } // VStack
    .padding()
  }

  // MARK: - Confirmation
  private var confirmationView: some View {
    VStack(spacing: 16) {
      Spacer()

      Image(systemName: "envelope.badge.fill")
        .font(.system(size: 64))
        .foregroundStyle(.tint)

      Text("Check your inbox")
        .font(.title2)
        .fontWeight(.semibold)

      Text("We sent a sign-in link to\n**\(email)**")
        .font(.body)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)

      Spacer()

      Button {
        Task { await onSendLink() }
      } label: {
        Group {
          if isLoading {
            ProgressView()
          } else {
            Text("Resend Link")
          }
        } // Group
        .frame(maxWidth: .infinity)
      }
      .buttonStyle(.bordered)
      .controlSize(.large)

      Button {
        dismiss()
      } label: {
        Text("Done")
          .frame(maxWidth: .infinity)
      }
      .buttonStyle(.borderedProminent)
      .controlSize(.large)
    } // VStack
    .padding()
  }
}
