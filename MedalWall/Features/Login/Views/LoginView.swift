//
//  LoginView.swift
//  MedalWall
//
//  Created by Quien on 2026-04-19.
//

import SwiftUI
import SwiftData
import AuthenticationServices
import GoogleSignInSwift

struct LoginView: View {
  @Environment(UserManager.self) private var userManager
  @State private var viewModel = LoginViewModel()
  @State private var isPresentingEmailSignIn: Bool = false
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
          
          VStack {
            SignInWithAppleButton(
              .continue,
              onRequest: { request in
                viewModel.prepareAppleRequest(request)
              },
              onCompletion: { result in
                Task {
                  await viewModel.handleAppleCompletion(result)
                }
              }
            )
            .frame(maxWidth: .infinity, maxHeight: 50)
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(style: .wide)) {
              Task {
                await viewModel.signInWithGoogle()
              }
            }
            .padding(.top, 8)
            
            Button {
              Task {
                if await viewModel.isConnected() {
                  isPresentingEmailSignIn = true
                } else {
                  errorWrapper = ErrorWrapper(error: .noInternetConnection)
                }
              }
            } label: {
              Label("Continue with Email", systemImage: "envelope")
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
            .controlSize(.large)
            .padding(.top, 8)
            
            Button("Continue as Guest") {
              //            try? userManager.startAsGuest()
            }
            .font(.subheadline)
            .foregroundStyle(Color.Text.secondary)
            .padding(.top, 12)
          } // VStack
          .padding(.top)
          .padding(.horizontal, 16)
        } // VStack
      }
    } // ZStack
    .sheet(isPresented: $isPresentingEmailSignIn, onDismiss: viewModel.resetEmailFlow) {
      SignInWithEmailLinkView(
        email: $viewModel.email,
        isLoading: viewModel.isLoading,
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
