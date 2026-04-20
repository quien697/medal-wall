//
//  EditProfileInfoSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-18.
//

import SwiftUI

struct EditProfileInfoSection: View {
  @Binding var firstName: String
  @Binding var lastName: String
  @Binding var gender: Gender?
  @Binding var birthday: Date
  @Binding var isBirthdaySet: Bool
  
  var body: some View {
    Section("Info") {
      LabeledContent {
        TextField("First Name", text: $firstName)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("First Name")
          .fromLabelStyle()
      }
      
      LabeledContent {
        TextField("Last Name", text: $lastName)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("Last Name")
          .fromLabelStyle()
      }
      
      Picker(selection: $gender) {
        Text("Not Set").tag(Gender?.none)
        
        ForEach(Gender.allCases, id: \.self) { g in
          Text(g.displayName).tag(Gender?.some(g))
        }
      } label: {
        Text("Gender")
          .fromLabelStyle()
      }
      
      LabeledContent {
        if isBirthdaySet {
          HStack {
            Button {
              isBirthdaySet = false
              birthday = .now
            } label: {
              Image(systemName: "xmark.circle.fill")
            }
            .tint(.red)
            .buttonStyle(.plain)
            
            DatePicker("", selection: $birthday, displayedComponents: .date)
              .labelsHidden()
          }
        } else {
          Button("Not Set") {
            isBirthdaySet = true
          }
          .tint(Color.Text.primary)
          .buttonStyle(.bordered)
        }
      } label: {
        Text("Birthday")
          .fromLabelStyle()
      }
    }
  }
}

#Preview {
  Form {
    EditProfileInfoSection(
      firstName: .constant("John"),
      lastName: .constant("Doe"),
      gender: .constant(.male),
      birthday: .constant(.now),
      isBirthdaySet: .constant(true)
    )
  }
}
