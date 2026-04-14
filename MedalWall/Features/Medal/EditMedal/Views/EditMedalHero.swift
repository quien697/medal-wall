//
//  EditMedalHero.swift
//  MedalWall
//
//  Created by Quien on 2026-04-13.
//

import SwiftUI

struct EditMedalHero: View {
  // MARK: - State
  @State private var isPresentingConfirmation: Bool = false
  // MARK: - Properties
  let photo: UIImage?
  let onChooseFromLibrary: () -> Void
  let onCrop: () -> Void
  let onRemove: () -> Void
  
  var body: some View {
    Button {
      isPresentingConfirmation = true
    } label: {
      VStack(spacing: 8) {
        MedalImage(photo: photo)
          .confirmationDialog(
            "Edit Photo",
            isPresented: $isPresentingConfirmation,
            titleVisibility: .visible
          ) {
            Button("Choose from Library") {
              onChooseFromLibrary()
            }
            
            if photo != nil {
              Button("Crop Photo") {
                onCrop()
              }
              
              Button("Remove Photo", role: .destructive) {
                onRemove()
              }
            }
          } // confirmationDialog
        
        Text("Tap to \(photo == nil ? "add a new" : "update the") medal photo")
          .font(.subheadline)
          .foregroundStyle(Color.Text.tertiary)
      } // VStack
      .frame(maxWidth: .infinity)
      .padding(.bottom, 16)
      .background(Color.Card.Background.secondary)
      .overlay(alignment: .bottom) {
        Rectangle()
          .fill(Color.Border.gray)
          .frame(height: 1)
      }
    } // Button
  }
}

#Preview {
  EditMedalHero(
    photo: nil,
    onChooseFromLibrary: { print("onChooseFromLibrary") },
    onCrop: { print("onCrop") },
    onRemove: { print("onRemove") }
  )
}
