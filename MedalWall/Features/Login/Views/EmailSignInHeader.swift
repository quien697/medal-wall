//
//  EmailSignInHeader.swift
//  MedalWall
//
//  Created by Quien on 2026-05-08.
//

import SwiftUI

struct EmailSignInHeader: View {
  // MARK: - Properties
  let title: LocalizedStringKey
  let subTitle: LocalizedStringKey

  // MARK: - Body
  var body: some View {
    VStack(spacing: 16) {
      Image(systemName: "envelope.fill")
        .font(.system(size: 50))
        .foregroundStyle(Color.Gold.primary)

      Text(title)
        .font(.title)
        .fontWeight(.bold)
        .foregroundStyle(Color.Text.primary)

      Text(subTitle)
        .font(.body)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    }  // VStack
  }
}

#Preview {
  EmailSignInHeader(
    title: "What's your email?",
    subTitle: "Enter your email address and we'll send you a sign-in link. No password needed."
  )
}
