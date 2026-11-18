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
/// is framed as an 840 × 840 square.
struct EditMedalPhotosSection: View {
  let photo: (MedalFace) -> UIImage?
  let storedPhotoStatus: (MedalFace) -> StoredPhotoStatus?
  let onPick: (UIImage, MedalFace) -> Void
  let onRemove: (MedalFace) -> Void
  let onError: (AppError) -> Void

  var body: some View {
    Section {
      HStack(alignment: .top, spacing: .Space.row) {
        ForEach(MedalFace.allCases, id: \.self) { face in
          VStack(spacing: .Space.stack) {
            PhotoSlot(
              photo: photo(face),
              storedPhotoStatus: storedPhotoStatus(face),
              imageType: .medal,
              cropShape: .square,
              outputSide: 840,
              title: face.photoTitle,
              message: """
                Lay it flat on a plain surface and shoot from straight above, or hang it on a \
                plain wall. Keep everything else out of the shot, and use even light with no \
                flash.
                """,
              placeholderText: face.addTitle,
              onPick: { onPick($0, face) },
              onRemove: { onRemove(face) },
              onError: onError
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
  @Previewable @State var frontPhoto = UIImage(systemName: "medal.fill")?
    .withTintColor(.systemYellow, renderingMode: .alwaysOriginal)

  Form {
    EditMedalPhotosSection(
      photo: { $0 == .front ? frontPhoto : nil },
      storedPhotoStatus: { $0 == .back ? .failed : nil },
      onPick: { photo, face in if face == .front { frontPhoto = photo } },
      onRemove: { face in if face == .front { frontPhoto = nil } },
      onError: { _ in }
    )
  }  // Form
}
