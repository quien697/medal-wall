//
//  ProfileView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import SwiftData

struct ProfileView: View {
  @Environment(\.modelContext) private var context
  
  @Query private var users: [User]
  
  var body: some View {
    Group {
      if let user = users.first {
        ScrollView {
          CardSection {
            VStack {
              Image(.quien)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 100, height: 100)
                .clipShape(Circle())
              
              Text("\(user.firstName), \(user.lastName)")
                .font(.title)
              
              if let bio = user.bio {
                Text(bio)
                  .font(.headline)
              }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 50)
            .padding(.horizontal)
          }
          
          CardSection(title: "Info") {
            if let gender = user.gender {
              CardListItem(systemName: "person.fill") {
                Text(gender)
              }
            }
            
            if let birthday = user.birthday {
              CardListItem(systemName: "calendar") {
                Text("\(birthday.formatted(date: .abbreviated, time: .omitted))")
              }
            }
          }
        }
      } else {
        ContentUnavailableView {
          Label("No User Found", systemImage: "person.fill")
        } description: {
          Button {
            print("add a new user")
          } label: {
            Text("Creating a new user")
              .padding(.top, 10)
          }
        }
      }
    } // NavigationStack
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Settings", systemImage: "gearshape.fill") {
          
        }
      }
    } // toolbar
  }
}

#Preview(traits: .sampleData) {
  ProfileView()
}
