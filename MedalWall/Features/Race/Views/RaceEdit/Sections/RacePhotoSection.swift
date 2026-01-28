//
//  RacePhotoSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-26.
//

import SwiftUI
import PhotosUI

struct RacePhotoSection: View {
  @State private var isShowingPhotoDialog: Bool = false

  let photo: UIImage?
  let cropPhoto: UIImage?
  let onChooseFromLibrary: (() -> Void)
  let onCrop: (() -> Void)
  let onRemove: (() -> Void)

  var body: some View {
    Section("Race Image") {
      Group {
        if let uiImage = cropPhoto ?? photo {
          ZStack {
            Image(uiImage: uiImage)
              .raceHero()
          }
          .frame(maxWidth: .infinity)
        } else {
          ContentUnavailableView {
            VStack {
              Image(systemName: "photo.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 60)
                .foregroundStyle(.gray)
                .padding(.bottom, 10)
              
              Text("No Race Photo")
                .font(.headline)
                .foregroundStyle(.gray)
            } // VStack
            .frame(width: 240, height: 240)
            .background(.thinMaterial)
            .overlay(
              RoundedRectangle(cornerRadius: 12)
                .stroke(.gray, style: StrokeStyle(lineWidth: 2, dash: [10, 2]))
            )
          } // ContentUnavailableView
        }
      } // Group
      .confirmationDialog(
        "Edit Photo",
        isPresented: $isShowingPhotoDialog,
        titleVisibility: .visible
      ) {
        Button("Choose from Library") {
          onChooseFromLibrary()
        }

        if cropPhoto != nil || photo != nil {
          Button("Crop Photo") {
            onCrop()
          }
        }

        Button("Remove Photo", role: .destructive) {
          onRemove()
        }

        Button("Cancel", role: .cancel) {
          isShowingPhotoDialog = false
        }
      } // confirmationDialog

      Button {
        isShowingPhotoDialog = true
      } label: {
        Label("Edit Photo", systemImage: "photo")
          .font(.headline)
          .frame(maxWidth: .infinity)
          .foregroundStyle(.white)
          .padding()
          .background(.primary)
          .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
      }
    } // Section
  }
}

#Preview {
  let race = Race.sampleData.first!

  Form {
    RacePhotoSection(
      photo: race.photo,
      cropPhoto: race.cropPhoto,
      onChooseFromLibrary: { print("onChooseFromLibrary") },
      onCrop: { print("onCrop") },
      onRemove: { print("onRemove") }
    )

    RacePhotoSection(
      photo: nil,
      cropPhoto: nil,
      onChooseFromLibrary: { print("onChooseFromLibrary") },
      onCrop: { print("onCrop") },
      onRemove: { print("onRemove") }
    )
  }
}
