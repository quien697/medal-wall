//
//  RaceEditionEditLogoSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-27.
//

import SwiftUI
import PhotosUI

struct RaceEditionEditLogoSection: View {
  @State private var isShowingPhotoDialog: Bool = false
  let photo: UIImage?
  let cropPhoto: UIImage?
  let onChooseFromLibrary: (() -> Void)
  let onCrop: (() -> Void)
  let onRemove: (() -> Void)
  
  var body: some View {
    Section("Logo") {
      HStack(spacing: 15) {
        Group {
          if let uiImage = cropPhoto ?? photo {
            Image(uiImage: uiImage)
              .styled(as: .raceThumbnail)
          } else {
            Image(systemName: "camera.fill")
              .placeholderStyled(as: .raceThumbnail)
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
        
        VStack(alignment: .leading, spacing: 5) {
          Text("Logo")
            .font(.headline)
          
          Text("(Optional) Leave empty to use race logo")
            .font(.caption)
            .foregroundStyle(Color.Text.tertiary)
        } // VStack
        
        Spacer()
        
        Button("\(photo == nil && cropPhoto == nil ? "Add" : "Edit")") {
          isShowingPhotoDialog = true
        }
        .goldFillButtonStyle()
      } // HStack
    } // Section
  }
}

#Preview {
  let edition = Race.sampleData.first!.editions.first!
  
  Form {
    RaceEditionEditLogoSection(
      photo: edition.photo,
      cropPhoto: edition.cropPhoto,
      onChooseFromLibrary: { print("onChooseFromLibrary") },
      onCrop: { print("onCrop") },
      onRemove: { print("onRemove") }
    )
    
    RaceEditionEditLogoSection(
      photo: nil,
      cropPhoto: nil,
      onChooseFromLibrary: { print("onChooseFromLibrary") },
      onCrop: { print("onCrop") },
      onRemove: { print("onRemove") }
    )
  }
}
