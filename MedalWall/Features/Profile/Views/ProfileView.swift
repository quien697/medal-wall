//
//  ProfileView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
  @State private var isShowProfileAddView = false
  @State private var isShowSettingsView = false
  
  @Query private var users: [User]
  
  private var user: User? { users.first }
  
  var body: some View {
    Group {
      if let user {
        ScrollView {
          CardSection(spacing: 16) {
            AvatarImage(photo: user.avatar)
            
            Text("\(user.firstName), \(user.lastName)")
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
              CardRow(icon: "person.fill", value: "-")
            }
          
            if let birthday = user.birthday {
              CardRow(
                icon: "calendar",
                value: birthday.formatted(date: .abbreviated, time: .omitted),
                withBottomLine: false
              )
            } else {
              CardRow(icon: "calendar", value: "-")
            }
          } // CardSection
        } // ScrollView
        .toolbar {
          ToolbarItem(placement: .topBarTrailing) {
            Button("Settings", systemImage: "gearshape.fill") {
              isShowSettingsView = true
            }
          }
        } // toolbar
      } else {
        ContentUnavailableView {
          Label("No User Found", systemImage: "person.fill")
        } description: {
          Button {
            isShowProfileAddView = true
          } label: {
            Text("Creating a new user")
              .padding(.top, 10)
          }
        } // ContentUnavailableView
      }
    } // Group
    .sheet(isPresented: $isShowProfileAddView) {
      NavigationStack {
        ProfileAddView()
      }
    }
    .sheet(isPresented: $isShowSettingsView) {
      NavigationStack{
        SettingsView()
      }
    }
  }
}

#Preview(traits: .sampleData) {
  ProfileView()
}
