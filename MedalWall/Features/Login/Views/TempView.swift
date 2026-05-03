//
//  TempView.swift
//  MedalWall
//
//  Created by Quien on 2026-04-30.
//

import SwiftUI
import SwiftData
import FirebaseAuth

struct TempView: View {
  @Environment(UserManager.self) private var userManager
  
  var body: some View {
    VStack(spacing: 20) {
      Text("Auth Test")
        .font(.largeTitle)
        .fontWeight(.bold)
      
      Divider()
      
      if let firebaseUser = userManager.firebaseUser {
        VStack(alignment: .leading, spacing: 8) {
          Label("Firebase User", systemImage: "person.fill.checkmark")
            .font(.headline)
          Text("UID: \(firebaseUser.uid)")
            .font(.caption)
            .foregroundStyle(.secondary)
          if let email = firebaseUser.email {
            Text("Email: \(email)")
          }
          if let name = firebaseUser.displayName {
            Text("Name: \(name)")
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
      } else if let localUser = userManager.currentUser {
        VStack(alignment: .leading, spacing: 8) {
          Label("Guest User", systemImage: "person.fill")
            .font(.headline)
          Text(localUser.fullName)
          Text("Local only — not signed in to Firebase")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
      }
      
      Spacer()
      
      if userManager.firebaseUser != nil {
        Button("Sign Out") {
          try? userManager.signOut()
        }
        .buttonStyle(.borderedProminent)
        .tint(.red)
        .controlSize(.large)
      }
    }
    .padding()
  }
}

#Preview {
  @Previewable @Environment(\.modelContext) var modelContext
  
  TempView()
    .environment(UserManager(modelContext: modelContext))
}
