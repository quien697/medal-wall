//
//  SignInButton.swift
//  MedalWall
//
//  Created by Quien on 2026-05-05.
//

import SwiftUI

struct SignInButton: View {
  // MARK: - Properties
  private let icon: Image?
  private let title: String
  private let action: () async -> Void

  // MARK: - Init
  init(
    icon: Image? = nil,
    title: String,
    action: @escaping () async -> Void
  ) {
    self.icon = icon
    self.title = title
    self.action = action
  }

  // MARK: - Body
  var body: some View {
    Button {
      Task {
        await action()
      }
    } label: {
      HStack(spacing: 10) {
        if let icon {
          icon
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
        }
        
        Text(title)
      } // HStack
      .frame(maxWidth: .infinity)
    } // label
    .primaryButtonStyle(
      font: .default,
      fontWeight: .semibold,
      vPadding: 16,
    )
  }
}

#Preview {
  VStack(spacing: 12) {
    SignInButton(icon: Image(systemName: "apple.logo"), title: "Continue with Apple") {}
    SignInButton(title: "Continue with Google") {}
    SignInButton(icon: Image(systemName: "envelope"), title: "Continue with Email") {}
  } // VStack
  .padding()
}
