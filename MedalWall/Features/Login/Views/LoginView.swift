//
//  LoginView.swift
//  MedalWall
//
//  Created by Quien on 2026-04-19.
//

import SwiftUI

struct LoginView: View {
  @Environment(UserManager.self) private var userManager
  @State private var viewModel = LoginViewModel()
  @State private var errorWrapper: ErrorWrapper?

  var body: some View {
    ZStack {
      Color.Background.primary.ignoresSafeArea()

      VStack {
        RingSeal(.record, size: .hero) {
          Text(verbatim: "MW")
            .font(.TypeScale.Wordmark.monogram)
            .tracking(.Tracking.monogram)
            .foregroundStyle(Color.Record.earned)
        }  // RingSeal
        .padding(.bottom, 16)

        Text("Medal Wall")
          .font(.TypeScale.Wordmark.name)
          .tracking(.Tracking.wordmark)
          .foregroundStyle(Color.Text.primary)
          .padding(.bottom, 8)

        Text("Sign up or log in to start collecting your medals")
          .font(.TypeScale.callout)
          .foregroundStyle(Color.Text.secondary)
          .multilineTextAlignment(.center)

        VStack(spacing: 16) {
          SignInButton(
            title: "Continue with Apple",
            systemImage: "apple.logo",
            isLoading: viewModel.activeSignIn == .apple
          ) {
            await viewModel.signInWithApple()
          }

          SignInButton(
            title: "Continue with Google",
            image: "google-icon",
            isLoading: viewModel.activeSignIn == .google
          ) {
            await viewModel.signInWithGoogle()
          }

          SignInButton(
            title: "Continue with Email",
            systemImage: "envelope"
          ) {
            await viewModel.signInWithEmailLink()
          }
        }  // VStack
        .allowsHitTesting(!viewModel.isSigningIn)
        .padding(.top)
        .padding(.horizontal, 16)
      }  // VStack
    }  // ZStack
    .sheet(isPresented: $viewModel.isPresentingEmailSignIn, onDismiss: viewModel.resetEmailFlow) {
      SignInWithEmailLinkView(
        email: $viewModel.email,
        isEmailLinkSent: viewModel.isEmailLinkSent,
        isEmailValid: viewModel.isEmailValid,
        isSendingEmail: viewModel.isSendingEmail,
        onSendLink: viewModel.sendEmailLink
      )
    }
    .sheet(item: $errorWrapper) {
      ErrorView(errorWrapper: $0)
    }
    .onChange(of: viewModel.error) { _, newError in
      if let newError {
        errorWrapper = ErrorWrapper(error: newError)
        viewModel.error = nil
      }
    }
    // `initial`: a link that opened the app may have failed before this screen appeared.
    .onChange(of: userManager.signInError, initial: true) { _, newError in
      if let newError {
        errorWrapper = ErrorWrapper(error: newError)
        userManager.signInError = nil
      }
    }
  }
}

#Preview {
  LoginView()
    .environment(UserManager())
}
