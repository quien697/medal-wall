//
//  ProfileEditView.swift
//  MedalWall
//
//  Created by Quien on 2025-12-02.
//

import SwiftUI
import PhotosUI
import SwiftData

struct ProfileEditView: View {
  @Query private var users: [User]
  
  private var user: User? { users.first }
  
  var body: some View {
    if let user = users.first {
      ProfileEditForm(profile: user)
    } else {
      ContentUnavailableView {
        Label("No User Found", systemImage: "person.fill")
      }
    }
  }
}

#Preview(traits: .sampleData) {
  ProfileEditView()
}
