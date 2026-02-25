//
//  ProfileView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
  @State private var isShowingProfileAddView = false
  @State private var isShowingSettingsView = false
  
  @Query private var users: [User]
  
  private var user: User? { users.first }
  
  var body: some View {
    Group {
      if let user {
        ScrollView {
          CardSection(spacing: 16) {
            AvatarImage(
              photo: user.avatar,
              cropPhoto: user.cropAvatar
            )
            
            Text("\(user.fullName)")
              .font(.title)
            
            if let bio = user.bio, !bio.isEmpty {
              Text(bio)
                .font(.headline)
                .foregroundStyle(.secondary)
            }
          } // CardSection
          
          CardSection(title: "Info", alignment: .leading, spacing: 10) {
            if let gender = user.genderEnum {
              CardRow(icon: "person.fill", value: gender.displayName)
            } else {
              CardRow(icon: "person.fill", value: "Not Set")
            }
            
            if let birthday = user.birthday {
              CardRow(
                icon: "calendar",
                value: birthday.formatted(date: .abbreviated, time: .omitted),
                withBottomLine: false
              )
            } else {
              CardRow(icon: "calendar", value: "Not Set")
            }
          } // CardSection
        } // ScrollView
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button("Settings", systemImage: "gearshape.fill") {
              isShowingSettingsView = true
            }
          }
        } // toolbar
      } else {
        ContentUnavailableView {
          Label("No User Found", systemImage: "person.fill")
        } description: {
          Button {
            isShowingProfileAddView = true
          } label: {
            Text("Creating a new user")
              .padding(.top, 10)
          }
        } // ContentUnavailableView
      }
    } // Group
    .sheet(isPresented: $isShowingProfileAddView) {
      NavigationStack {
        ProfileAddView()
      }
    }
    .sheet(isPresented: $isShowingSettingsView) {
      NavigationStack{
        SettingsView()
      }
    }
  }
}

#Preview(traits: .sampleData) {
  ProfileView()
}
