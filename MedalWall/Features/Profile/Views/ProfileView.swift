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
          CardSection {
            VStack(alignment: .center, spacing: 16) {
              if let uiImage = user.avatar {
                Image(uiImage: uiImage)
                  .avatar()
              } else {
                Image(systemName: "person.circle.fill")
                  .avatar()
                  .foregroundStyle(.gray)
              }
              
              Text("\(user.firstName), \(user.lastName)")
                .font(.title)
              
              if let bio = user.bio, !bio.isEmpty {
                Text(bio)
                  .font(.headline)
              }
            } // VStack
            .frame(maxWidth: .infinity)
          } // CardSection
          
          CardSection(title: "Info") {
            if let gender = user.genderEnum {
              CardListItem(systemName: "person.fill") {
                Text(gender.displayName)
              }
            }
            
            if let birthday = user.birthday {
              CardListItem(systemName: "calendar") {
                Text("\(birthday.formatted(date: .abbreviated, time: .omitted))")
              }
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
