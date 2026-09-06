//
//  SignInButton.swift
//  MedalWall
//
//  Created by Quien on 2026-05-05.
//

import SwiftUI

struct SignInButton: View {
  // MARK: - Properties
  private let icon: String?
  private let title: LocalizedStringKey
  private let isLoading: Bool
  private let action: () async -> Void

  // MARK: - Init
  init(
    icon: String? = nil,
    title: LocalizedStringKey,
    isLoading: Bool = false,
    action: @escaping () async -> Void
  ) {
    self.icon = icon
    self.title = title
    self.isLoading = isLoading
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
        if isLoading {
          ProgressView()
        } else if let icon {
          Image(systemName: icon)
            .resizable()
            .scaledToFit()
            .frame(width: 20, height: 20)
        }

        Text(title)
      }  // HStack
    }  // label
    .actionStyle(.tertiary, shape: .roundedRectangle)
  }
}

#Preview {
  VStack(spacing: 12) {
    SignInButton(icon: "apple.logo", title: "Continue with Apple") {}
    SignInButton(
      icon: "apple.logo", title: "Continue with Apple", isLoading: true
    ) {}
    SignInButton(icon: "envelope", title: "Continue with Email") {}
  }  // VStack
  .padding()
}
