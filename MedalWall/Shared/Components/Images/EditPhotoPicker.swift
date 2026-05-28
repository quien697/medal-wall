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
  let hint: String?
  @ViewBuilder let photoView: () -> Preview
  let onChooseFromLibrary: () -> Void
  let onRemove: () -> Void

  init(
    photo: UIImage?,
    hint: String? = nil,
    @ViewBuilder photoView: @escaping () -> Preview,
    onChooseFromLibrary: @escaping () -> Void,
    onRemove: @escaping () -> Void
  ) {
    self.photo = photo
    self.hint = hint
    self.photoView = photoView
    self.onChooseFromLibrary = onChooseFromLibrary
    self.onRemove = onRemove
  }

  // MARK: - Computed
  private var displayHint: String {
    hint ?? (photo == nil ? "Tap to add a photo" : "Tap to update the photo")
  }

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
          }  // confirmationDialog

        Text(displayHint)
          .font(.subheadline)
          .multilineTextAlignment(.center)
          .foregroundStyle(Color.Text.tertiary)
      }  // VStack
      .frame(maxWidth: .infinity)
    }  // Button
    .buttonStyle(.plain)
  }
}
