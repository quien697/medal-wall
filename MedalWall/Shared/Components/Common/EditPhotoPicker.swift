//
//  EditPhotoPicker.swift
//  MedalWall
//
//  Created by Quien on 2026-04-17.
//

import SwiftUI

struct EditPhotoPicker<Preview: View>: View {
  // MARK: - State
  @State private var isPresentingConfirmation: Bool = false
  // MARK: - Properties
  let photo: UIImage?
  let hint: String
  @ViewBuilder let photoView: () -> Preview
  let onChooseFromLibrary: () -> Void
  let onCrop: (() -> Void)
  let onRemove: () -> Void
  
  // MARK: - Body
  var body: some View {
    Button {
      isPresentingConfirmation = true
    } label: {
      VStack(spacing: 8) {
        photoView()
          .confirmationDialog(
            "Edit Photo",
            isPresented: $isPresentingConfirmation,
            titleVisibility: .visible
          ) {
            Button("Choose from Library") { onChooseFromLibrary() }
            
            if photo != nil {
              Button("Remove Photo", role: .destructive) { onRemove() }
            }
          } // confirmationDialog
        
        Text(hint)
          .font(.subheadline)
          .multilineTextAlignment(.center)
          .foregroundStyle(Color.Text.tertiary)
      } // VStack
      .frame(maxWidth: .infinity)
    } // Button
    .buttonStyle(.plain)
  }
}
