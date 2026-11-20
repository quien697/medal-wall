//
//  EditMedalPhotosSection.swift
//  MedalWall
//
//  Created by Quien on 2026-11-03.
//

import CropImage
import SwiftUI

/// The medal form's two photo slots, Front then Back, each labelled with its face beneath.
/// They never change places, whichever is filled.
///
/// Each slot's options say how to shoot the medal against a clear background, and the photo
/// is cropped to a square, kept at the photo's own pixels.
struct EditMedalPhotosSection: View {
  let content: (MedalFace) -> PhotoSlotContent
  let onPick: (CroppedPhoto, MedalFace) -> Void
  let onRemove: (MedalFace) -> Void
  let onError: (AppError) -> Void
  let onCheckingChange: (Bool) -> Void

  var body: some View {
    Section {
      HStack(alignment: .top, spacing: .Space.row) {
        ForEach(MedalFace.allCases, id: \.self) { face in
          VStack(spacing: .Space.stack) {
            PhotoSlot(
              content: content(face),
              imageType: .medal,
              cropShape: .square,
              title: face.photoTitle,
              message: """
                Lay it flat on a plain surface and shoot from straight above, or hang it on a \
                plain wall. Keep everything else out of the shot, and use even light with no \
                flash.
                """,
              placeholderText: face.addTitle,
              onPick: { onPick($0, face) },
              onRemove: { onRemove(face) },
              onError: onError,
              onCheckingChange: onCheckingChange
            )  // PhotoSlot

            Text(face.title)
              .font(.TypeScale.label)
              .tracking(.Tracking.label)
              .textCase(.uppercase)
              .foregroundStyle(Color.Text.tertiary)
              .accessibilityHidden(true)
          }  // VStack
        }  // ForEach
      }  // HStack
      .listRowBackground(Color.clear)
      .listRowInsets(EdgeInsets())
      .padding(.top, .Space.inline)
      .padding(.horizontal, .Space.row)
    } header: {
      Text("Photos")
        .sectionTitleStyle()
    }  // Section
  }
}

#Preview {
  @Previewable @State var frontContent = PhotoSlotContent.photo(
    UIImage(systemName: "medal.fill")?
      .withTintColor(.systemYellow, renderingMode: .alwaysOriginal) ?? UIImage())

  Form {
    EditMedalPhotosSection(
      content: { $0 == .front ? frontContent : .failed },
      onPick: { photo, face in if face == .front { frontContent = .photo(photo.image) } },
      onRemove: { face in if face == .front { frontContent = .empty } },
      onError: { _ in },
      onCheckingChange: { _ in }
    )
  }  // Form
}
