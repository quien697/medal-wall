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
          .font(.title.bold())
        
        Text(errorWrapper.error.message)
          .font(.body)
          .multilineTextAlignment(.center)
        
        Text(errorWrapper.error.guidance)
          .font(.body)
          .multilineTextAlignment(.center)
        
        Button("Continue") {
          dismiss()
        }
        .buttonStyle(.borderedProminent)
      } // VStack
      .padding()
    } // NavigationStack
  }
}

private enum SampleError: Error {
  case errorRequired
}

#Preview {
  ErrorView(errorWrapper: ErrorWrapper(error: AppError.duplicateDistance))
}

