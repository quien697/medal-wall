//
//  RacePhotoSection.swift
//  MedalWall
//
//  Created by Quien on 2025-11-26.
//

import SwiftUI
import PhotosUI

struct RacePhotoSection: View {
  @Binding var data: Data?
  @Binding var image: UIImage?
  
  @State private var selectedItem: PhotosPickerItem? = nil
  @State private var buttonName: String = "Pick"
  
  var body: some View {
    Section("Race Image") {
      ZStack {
        if let uiImage = image {
          Image(uiImage: uiImage)
            .raceHero()
            .overlay(alignment: .topTrailing) {
              Button {
                selectedItem = nil
                self.data = nil
                self.image = nil
              } label: {
                Image(systemName: "xmark")
                  .font(.system(size: 15))
                  .padding(8)
                  .background(.black)
                  .foregroundStyle(.white)
                  .clipShape(.circle)
                  .shadow(radius: 2)
              }
              .padding(-10)
            }
        } else {
          ContentUnavailableView {
            Image(systemName: "photo.fill")
              .resizable()
              .scaledToFit()
              .frame(width: 60)
              .foregroundStyle(.gray)
              .padding(.bottom, 10)
            
            Text("No Race Photo")
              .font(.headline)
              .foregroundStyle(.gray)
          }
          .background(.thinMaterial)
          .frame(width: 240, height: 240)
          .overlay(
            RoundedRectangle(cornerRadius: 12)
              .stroke(.gray, style: StrokeStyle(lineWidth: 2, dash: [10, 2]))
          )
        }
      } // ZStack
      .frame(maxWidth: .infinity)
      .padding()
      
      VStack(alignment: .center) {
        PhotosPicker(
          selection: $selectedItem,
          matching: .images,
          photoLibrary: .shared()
        ) {
          HStack(alignment: .center) {
            Text("Pcik Photo")
              .font(.headline)
              .frame(maxWidth: .infinity)
              .foregroundStyle(.white)
              .padding()
          }
        }
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
      .background(.blue)
      .clipShape(.rect(cornerRadius: 12))
    } // Section
  }
}

#Preview {
  let race = Race.sampleData.first!
  
  Form {
    RacePhotoSection(data: .constant(race.photoData), image: .constant(race.photo))
  }
}
