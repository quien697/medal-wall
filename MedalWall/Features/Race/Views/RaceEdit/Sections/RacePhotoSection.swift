//
//  RacePhotoSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-26.
//

import SwiftUI
import PhotosUI

struct RacePhotoSection: View {
  @State private var selectedPhotoItem: PhotosPickerItem?
  @State private var isShowingPhotosPicker: Bool = false
  @State private var isShowingPhotoDialog: Bool = false
  @State private var errorWrapper: ErrorWrapper?
  
  @Binding var data: Data?
  @Binding var image: UIImage?
  
  var body: some View {
    Section("Race Image") {
      Group {
        if let uiImage = image {
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
          isShowingPhotosPicker = true
        }
        
        Button("Remove Photo", role: .destructive) {
          data = nil
          image = nil
          selectedPhotoItem = nil
        }
        
        Button("Cancel", role: .cancel) { isShowingPhotoDialog = false }
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
          .clipShape(.rect(cornerRadius: 12))
      }
    } // Section
    .photosPicker(isPresented: $isShowingPhotosPicker, selection: $selectedPhotoItem)
    .onChange(of: selectedPhotoItem) { _, newItem in
      guard let newItem else { return }
      
      Task {
        do {
          if let data = try await newItem.loadTransferable(type: Data.self),
             let image = UIImage(data: data) {
            self.data = data
            self.image = image
          } else {
            errorWrapper = ErrorWrapper(error: AppError.photoDataInvalid)
          }
        } catch {
          errorWrapper = ErrorWrapper(error: AppError.photoLoadFailed)
        }
      } // Task
    } // onChange
    .sheet(item: $errorWrapper, onDismiss: nil) { wrapper in
      ErrorView(errorWrapper: wrapper)
    }
  }
}

#Preview {
  let race = Race.sampleData.first!
  
  Form {
    RacePhotoSection(data: .constant(race.photoData), image: .constant(race.photo))
    RacePhotoSection(data: .constant(race.photoData), image: .constant(nil))
  }
}
