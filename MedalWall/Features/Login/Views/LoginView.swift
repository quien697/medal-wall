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
            .padding(.bottom, 36)
          
          Text("Medal Wall")
            .font(.largeTitle)
            .foregroundStyle(Color.Text.primary)
            .fontWeight(.heavy)
            .padding(.bottom, 8)
          
          Text("Your personal race archive")
            .font(.subheadline)
            .foregroundStyle(Color.Text.secondary)
          
          Spacer()
          
          Button("Get Started with Guest") {
            try? userManager.startAsGuest()
          }
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          
          SignInWithAppleButton(
            onRequest: { request in
              viewModel.prepareAppleRequest(request)
            },
            onCompletion: { result in
              Task {
                await viewModel.handleAppleCompletion(result)
              }
            }
          )
          .frame(height: 50)
          .padding(.top, 8)
          
          GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(style: .wide)) {
            Task {
              await viewModel.signInWithGoogle()
            }
          }
        } // VStack
        .padding(.top, 52)
        .padding(.bottom, 36)
        .padding(.horizontal, 24)
      }
    } // ZStack
    .alert(viewModel.error?.title ?? "Sign In Failed", isPresented: .constant(viewModel.error != nil)) {
      Button("OK") { viewModel.error = nil }
    } message: {
      Text(viewModel.error?.message ?? "")
    }
  }
}

#Preview {
  @Previewable @Environment(\.modelContext) var modelContext
  LoginView()
    .environment(UserManager(modelContext: modelContext))
}
