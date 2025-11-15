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
      VStack {
        ZStack {
          Color.red
          
          Image(systemName: "exclamationmark.triangle.fill")
            .font(.system(size: 128))
        }
        .frame(height: 250)
        
        VStack {
          Text("Oops!")
            .font(.largeTitle)
            .padding(.bottom)
          
          Text(errorWrapper.error.localizedDescription)
            .font(.headline)
          
          Text(errorWrapper.guidance)
            .font(.caption)
            .padding(.top)
        }
        .padding(.horizontal, 20)
        
        Spacer()
      } // VStack
      .ignoresSafeArea()
      .toolbar {
        ToolbarItem(placement: .navigationBarTrailing) {
          Button {
            dismiss()
          } label: {
            Image(systemName: "xmark")
          }
        }
      } // toolbar
    } // NavigationStack
  }
}

private enum SampleError: Error {
  case errorRequired
}

#Preview {
  ErrorView(errorWrapper: ErrorWrapper(error: SampleError.errorRequired, guidance: "You can safely ignore this error."))
}

