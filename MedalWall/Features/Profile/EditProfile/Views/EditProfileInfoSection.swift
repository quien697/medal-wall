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
  @Binding var birthday: Date?

  var body: some View {
    Section {
      LabeledContent {
        TextField("First Name", text: $firstName)
          .fromStyle(.value)
      } label: {
        Text("First Name")
          .fromStyle(.label)
      }

      LabeledContent {
        TextField("Last Name", text: $lastName)
          .fromStyle(.value)
      } label: {
        Text("Last Name")
          .fromStyle(.label)
      }

      Picker(selection: $gender) {
        Text("Not Set")
          .tag(Gender?.none)

        ForEach(Gender.allCases, id: \.self) { genderCase in
          Text(genderCase.displayName)
            .tag(Gender?.some(genderCase))
        }
      } label: {
        Text("Gender")
          .fromStyle(.label)
      }
      .pickerStyle(.menu)

      LabeledContent {
        if let selection = Binding($birthday) {
          DatePicker("", selection: selection, in: ...Date.now, displayedComponents: .date)
            .labelsHidden()
        } else {
          Button("Not Set") {
            birthday = .now
          }
          .actionStyle(.neutral, font: .TypeScale.Field.value)
        }
      } label: {
        Text("Birthday")
          .fromStyle(.label)
      }
    } header: {
      Text("Info")
        .sectionTitleStyle()
    }  // Section
    .listRowBackground(Color.Surface.primary)
  }
}

#Preview("Birthday Not Set") {
  Form {
    EditProfileInfoSection(
      firstName: .constant("John"),
      lastName: .constant("Doe"),
      gender: .constant(.none),
      birthday: .constant(nil)
    )
  }
}

#Preview("Birthday Set") {
  Form {
    EditProfileInfoSection(
      firstName: .constant("John"),
      lastName: .constant("Doe"),
      gender: .constant(.male),
      birthday: .constant(.now)
    )
  }
}
