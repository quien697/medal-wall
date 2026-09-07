//
//  ErrorView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-15.
//

import SwiftUI

struct ErrorView: View {
  @Environment(\.dismiss) private var dismiss
  let errorWrapper: ErrorWrapper

  var body: some View {
    NavigationStack {
      VStack(spacing: 16) {
        Image(systemName: "exclamationmark.triangle.fill")
          .font(.system(size: 72))
          .foregroundStyle(.yellow)
          .padding(.bottom, 10)

        Text(errorWrapper.error.title)
          .font(.TypeScale.title2)
          .foregroundStyle(Color.Text.primary)

        Text(errorWrapper.error.message)
          .font(.TypeScale.body)
          .foregroundStyle(Color.Text.secondary)
          .multilineTextAlignment(.center)

        Text(errorWrapper.error.guidance)
          .font(.TypeScale.body)
          .foregroundStyle(Color.Text.secondary)
          .multilineTextAlignment(.center)

        Button("Continue") {
          dismiss()
        }
        .buttonStyle(.borderedProminent)
      }  // VStack
      .padding()
    }  // NavigationStack
  }
}

#Preview {
  ErrorView(errorWrapper: ErrorWrapper(error: AppError.duplicateDistance))
}
