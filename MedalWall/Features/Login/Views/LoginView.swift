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
  @State private var isLoading = false
  
  var body: some View {
    ZStack {
      Color.Background.primary.ignoresSafeArea()
      
      if isLoading {
        LoadingView(text: "Setting up...")
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
            isLoading = true
            
            Task {
              try? userManager.startAsGuest()
            }
          }
          .buttonStyle(.borderedProminent)
          .controlSize(.large)
          
        } // VStack
        .padding(.top, 52)
        .padding(.bottom, 36)
      }
    } // ZStack
  }
}

#Preview {
  @Previewable @Environment(\.modelContext) var modelContext
  
  LoginView()
    .environment(UserManager(modelContext: modelContext))
}
