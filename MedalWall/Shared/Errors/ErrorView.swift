//
//  ErrorView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-15.
//

import SwiftUI

/// A sheet presenting an `AppError` as what failed, why, and what to do next.
struct ErrorView: View {
  @Environment(\.dismiss) private var dismiss
  let errorWrapper: ErrorWrapper

  var body: some View {
    VStack(spacing: .Space.section) {
      Image(systemName: "exclamationmark.triangle.fill")
        .font(.system(size: 72))
        .foregroundStyle(Color.Status.error)

      VStack(spacing: .Space.stack) {
        Text(errorWrapper.error.title)
          .font(.TypeScale.title1)
          .foregroundStyle(Color.Text.primary)

        VStack(spacing: .Space.stack) {
          Text(errorWrapper.error.message)
          Text(errorWrapper.error.guidance)
        }  // VStack
        .font(.TypeScale.body)
        .foregroundStyle(Color.Text.secondary)
      }  // VStack
      .multilineTextAlignment(.center)

      Button("Continue") {
        dismiss()
      }  // Button
      .actionStyle(.primary, shape: .roundedRectangle)
    }  // VStack
    .padding(.Space.panel)
  }
}

#Preview("Validation") {
  ErrorView(errorWrapper: ErrorWrapper(error: .duplicateDistance))
}

#Preview("Server Description") {
  ErrorView(
    errorWrapper: ErrorWrapper(
      error: .sendEmailSignInLinkFailed("The email address is badly formatted.")
    )
  )
}

/// Presented rather than rendered directly, because the sheet is what a user sees:
/// its corner radius, drag indicator, and the dimmed screen behind it.
#Preview("As Sheet") {
  @Previewable @State var errorWrapper: ErrorWrapper? = ErrorWrapper(error: .medalDeleteFailed)

  Color.Background.primary
    .ignoresSafeArea()
    .sheet(item: $errorWrapper) { wrapper in
      ErrorView(errorWrapper: wrapper)
    }
}

/// Every family of error in one scroll, for comparing titles and guidance side by side.
#Preview("Gallery") {
  ScrollView {
    VStack(spacing: .Space.section) {
      ForEach(AppError.sampleData.indices, id: \.self) { index in
        ErrorView(errorWrapper: ErrorWrapper(error: AppError.sampleData[index]))

        Divider()
      }  // ForEach
    }  // VStack
  }  // ScrollView
  .background(Color.Background.primary)
}
