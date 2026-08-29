//
//  EditProfileBioSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-18.
//

import SwiftUI

struct EditProfileBioSection: View {
  @Binding var bio: String

  var body: some View {
    Section("Bio") {
      TextEditor(text: $bio)
        .font(.TypeScale.body)
        .frame(minHeight: 100)
    }
  }
}

#Preview {
  Form {
    EditProfileBioSection(bio: .constant("Running enthusiast"))
  }
}
