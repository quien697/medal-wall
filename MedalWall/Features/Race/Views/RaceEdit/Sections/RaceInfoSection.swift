//
//  RaceInfoSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-26.
//

import SwiftUI
import PhotosUI

struct RaceInfoSection: View {
  @State private var isShowingPhotoDialog: Bool = false
  @Binding var name: String
  @Binding var url: String
  let photo: UIImage?
  let cropPhoto: UIImage?
  let onChooseFromLibrary: (() -> Void)
  let onCrop: (() -> Void)
  let onRemove: (() -> Void)
  
  var body: some View {
    Section("Info") {
      HStack {
        Group {
          if let uiImage = cropPhoto ?? photo {
            Image(uiImage: uiImage)
              .styled(as: ImageType.raceHero)
          } else {
            Image(systemName: "photo.fill")
              .placeholderStyled(as: ImageType.raceHero)
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
        
        VStack(alignment: .leading) {
          Text("Race Logo")
            .font(.headline)
            .fontWeight(.bold)
          
          Text("(Optional) Used as race logo throughout the app")
            .font(.subheadline)
            .foregroundStyle(Color.Text.tertiary)
          
          Spacer()
          
          Button("\(photo == nil && cropPhoto == nil ? "Add" : "Edit")") {
            isShowingPhotoDialog = true
          }
          .goldFillButtonStyle()
        }
        .padding(.leading, 10)
      }
      
      LabeledContent {
        TextField("Name", text: $name)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("Name")
          .fontWeight(.bold)
          .foregroundStyle(Color.Text.tertiary)
      }
      
      LabeledContent {
        TextField("WebSite (optional)", text: $url)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("WebSite")
          .fontWeight(.bold)
          .foregroundStyle(Color.Text.tertiary)
      }
    } // Section
  }
}

#Preview {
  let race = Race.sampleData.first!
  
  Form {
    RaceInfoSection(
      name: .constant(race.name),
      url: .constant(race.url ?? ""),
      photo: race.photo,
      cropPhoto: race.cropPhoto,
      onChooseFromLibrary: { print("onChooseFromLibrary") },
      onCrop: { print("onCrop") },
      onRemove: { print("onRemove") }
    )
    
    RaceInfoSection(
      name: .constant(race.name),
      url: .constant(""),
      photo: nil,
      cropPhoto: nil,
      onChooseFromLibrary: { print("onChooseFromLibrary") },
      onCrop: { print("onCrop") },
      onRemove: { print("onRemove") }
    )
  }
}
