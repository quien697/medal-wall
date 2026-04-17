//
//  EditRaceEditionPhotoSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-27.
//

import SwiftUI
import PhotosUI

struct EditRaceEditionPhotoSection: View {
  @State private var isPresentingPhotoDialog: Bool = false
  let photo: UIImage?
  let cropPhoto: UIImage?
  let onChooseFromLibrary: (() -> Void)
  let onCrop: (() -> Void)
  let onRemove: (() -> Void)
  
  var body: some View {
    Section("Logo") {
      HStack(spacing: 15) {
        RaceImage(
          photo: cropPhoto ?? photo,
          imageType: .raceThumbnail
        )
        .confirmationDialog(
          "Edit Photo",
          isPresented: $isPresentingPhotoDialog,
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
            isPresentingPhotoDialog = false
          }
        } // confirmationDialog
        
        VStack(alignment: .leading, spacing: 5) {
          Text("Logo")
            .font(.headline)
          
          Text("(Optional) Leave empty to use race logo")
            .fromLabelStyle()
        } // VStack
        
        Spacer()
        
        Button("\(photo == nil && cropPhoto == nil ? "New" : "Edit")") {
          isPresentingPhotoDialog = true
        }
        .goldFillButtonStyle()
      } // HStack
    } // Section
  }
}

#Preview {
  let edition = Race.sampleData.first!.editions.first!
  
  Form {
    EditRaceEditionPhotoSection(
      photo: edition.photo,
      cropPhoto: edition.cropPhoto,
      onChooseFromLibrary: { print("onChooseFromLibrary") },
      onCrop: { print("onCrop") },
      onRemove: { print("onRemove") }
    )
    
    EditRaceEditionPhotoSection(
      photo: nil,
      cropPhoto: nil,
      onChooseFromLibrary: { print("onChooseFromLibrary") },
      onCrop: { print("onCrop") },
      onRemove: { print("onRemove") }
    )
  }
}
