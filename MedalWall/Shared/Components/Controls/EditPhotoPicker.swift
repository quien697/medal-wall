//
//  EditPhotoPicker.swift
//  MedalWall
//
//  Created by Quien on 2026-04-17.
//

import SwiftUI

struct EditPhotoPicker: View {
  // MARK: - State
  @State private var isPresentingConfirmation: Bool = false
  // MARK: - Properties
  let photo: UIImage?
  let imageType: ImageType
  let hint: String?
  let onChooseFromLibrary: () -> Void
  let onRemove: () -> Void

  init(
    photo: UIImage?,
    imageType: ImageType,
    hint: String? = nil,
    onChooseFromLibrary: @escaping () -> Void,
    onRemove: @escaping () -> Void
  ) {
    self.photo = photo
    self.imageType = imageType
    self.hint = hint
    self.onChooseFromLibrary = onChooseFromLibrary
    self.onRemove = onRemove
  }

  // MARK: - Computed
  private var displayHint: String {
    if let hint { return hint }

    return photo == nil
      ? .appLocalized("Tap to add a photo")
      : .appLocalized("Tap to update the photo")
  }

  // MARK: - Body
  var body: some View {
    Button {
      isPresentingConfirmation = true
    } label: {
      VStack(spacing: 8) {
        photoView
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
          .font(.TypeScale.caption)
          .multilineTextAlignment(.center)
          .foregroundStyle(Color.Text.tertiary)
      }  // VStack
      .frame(maxWidth: .infinity)
    }  // Button
    .buttonStyle(.plain)
  }

  /// The photo itself once there is one, and the slot inviting one until then.
  @ViewBuilder
  private var photoView: some View {
    if let photo {
      PhotoImage(photo: photo, as: imageType)
    } else {
      EmptyPhotoSlot(as: imageType)
    }
  }
}

#Preview("Empty") {
  Form {
    EditPhotoPicker(
      photo: nil,
      imageType: .medal,
      onChooseFromLibrary: {},
      onRemove: {}
    )
    .listRowBackground(Color.clear)
  }  // Form
}

#Preview("With photo") {
  Form {
    EditPhotoPicker(
      photo: UIImage(named: "bmo-vancouver-marathon"),
      imageType: .medal,
      onChooseFromLibrary: {},
      onRemove: {}
    )
    .listRowBackground(Color.clear)
  }  // Form
}
