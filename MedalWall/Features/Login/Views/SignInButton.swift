//
//  SignInButton.swift
//  MedalWall
//
//  Created by Quien on 2026-05-05.
//

import SwiftUI

struct SignInButton: View {
  // MARK: - Properties
  private let title: LocalizedStringKey
  private let icon: Image
  private let isLoading: Bool
  private let action: () async -> Void

  // MARK: - Init
  /// Creates a sign-in button whose icon is an SF Symbol, like `Label(_:systemImage:)`.
  init(
    title: LocalizedStringKey,
    systemImage: String,
    isLoading: Bool = false,
    action: @escaping () async -> Void
  ) {
    self.title = title
    self.icon = Image(systemName: systemImage)
    self.isLoading = isLoading
    self.action = action
  }

  /// Creates a sign-in button whose icon comes from the asset catalog, like `Label(_:image:)` —
  /// for brand marks such as Google's that SF Symbols does not include.
  init(
    title: LocalizedStringKey,
    image: String,
    isLoading: Bool = false,
    action: @escaping () async -> Void
  ) {
    self.title = title
    self.icon = Image(image)
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
        } else {
          icon
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
    SignInButton(title: "Continue with Apple", systemImage: "apple.logo") {}
    SignInButton(
      title: "Continue with Apple", systemImage: "apple.logo", isLoading: true
    ) {}
    SignInButton(title: "Continue with Google", image: "google-icon") {}
    SignInButton(title: "Continue with Email", systemImage: "envelope") {}
  }  // VStack
  .padding()
}
