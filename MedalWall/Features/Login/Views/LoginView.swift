//
//  LoginView.swift
//  MedalWall
//
//  Created by Quien on 2026-04-19.
//

import SwiftUI
import SwiftData

struct LoginView: View {
  @Environment(UserManager.self) private var userManager
  @State private var viewModel = LoginViewModel()
  @State private var errorWrapper: ErrorWrapper?
  
  var body: some View {
    ZStack {
      Color.Background.primary.ignoresSafeArea()
      
      if viewModel.isLoading {
        LoadingView(text: "Signing in...")
      } else {
        VStack {
          Image(systemName: "medal.fill")
            .font(.system(size: 100))
            .foregroundStyle(Color.Gold.primary)
            .padding(.bottom, 16)
          
          Text("Medal Wall")
            .font(.largeTitle)
            .foregroundStyle(Color.Text.primary)
            .fontWeight(.heavy)
            .padding(.bottom, 8)
          
          Text("Sign up or log in to start collecting your medals")
            .font(.subheadline)
            .foregroundStyle(Color.Text.secondary)
            .multilineTextAlignment(.center)
          
          VStack(spacing: 16) {
            SignInButton(
              icon: Image(systemName: "apple.logo"),
              title: "Continue with Apple")
            {
              await viewModel.signInWithApple()
            }
            
            SignInButton(
              icon: Image("google-icon"),
              title: "Continue with Google")
            {
              await viewModel.signInWithGoogle()
            }
            
            SignInButton(
              icon: Image(systemName: "envelope"),
              title: "Continue with Email")
            {
              await viewModel.signInWithEmailLink()
            }
          } // VStack
          .padding(.top)
          .padding(.horizontal, 16)
        } // VStack
      }
    } // ZStack
    .sheet(isPresented: $viewModel.isPresentingEmailSignIn, onDismiss: viewModel.resetEmailFlow) {
      SignInWithEmailLinkView(
        email: $viewModel.email,
//        isLoading: viewModel.isLoading,
        isEmailLinkSent: viewModel.isEmailLinkSent,
        isEmailValid: viewModel.isEmailValid,
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
  }
}

#Preview {
  @Previewable @Environment(\.modelContext) var modelContext
  LoginView()
    .environment(UserManager(modelContext: modelContext))
}
