//
//  RacePhotoSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-26.
//

import SwiftUI
import PhotosUI

struct RacePhotoSection: View {
  @State private var selectedItem: PhotosPickerItem? = nil
  @Binding var data: Data?
  @Binding var image: UIImage?
  
  var body: some View {
    Section("Race Image") {
      PhotosPicker(
        selection: $selectedItem,
        matching: .images,
        photoLibrary: .shared()
      ) {
        if let uiImage = image {
          Image(uiImage: uiImage)
            .resizable()
            .scaledToFill()
            .clipShape(.rect(cornerRadius: 12))
            .overlay(alignment: .topTrailing) {
              Button {
                selectedItem = nil
                self.data = nil
                self.image = nil
              } label: {
                Image(systemName: "xmark.circle.fill")
                  .font(.system(size: 32))
                  .symbolRenderingMode(.hierarchical)
                  .foregroundStyle(.white)
                  .shadow(radius: 2)
              }
              .padding()
            }
        } else {
          ContentUnavailableView {
            Image(systemName: "photo.fill")
              .resizable()
              .scaledToFit()
              .frame(width: 60)
              .padding(.bottom, 10)
            
            Text("Add Photo")
              .font(.headline)
          }
          .background(.thinMaterial)
          .frame(height: 250)
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [10, 2]))
          )
        }
      } // PhotosPicker
      .onChange(of: selectedItem) { _, newItem in
        guard let newItem else { return }
        
        Task {
          if let data = try await newItem.loadTransferable(type: Data.self),
             let image = UIImage(data: data) {
            self.data = data
            self.image = image
          }
        }
      } // onChange
    }
  }
}

#Preview {
  let race = Race.sampleData.first!
  
  Form {
    RacePhotoSection(data: .constant(race.photoData), image: .constant(race.photo))
  }
}
