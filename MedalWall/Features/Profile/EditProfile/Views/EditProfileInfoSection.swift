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
          .font(.TypeScale.Field.value)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("First Name")
          .font(.TypeScale.Field.label)
          .foregroundStyle(Color.Text.tertiary)
      }

      LabeledContent {
        TextField("Last Name", text: $lastName)
          .font(.TypeScale.Field.value)
          .multilineTextAlignment(.trailing)
      } label: {
        Text("Last Name")
          .fromLabelStyle()
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
          .fromLabelStyle()
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
          .actionStyle(
            .neutral,
            font: .TypeScale.Field.value,
            vPadding: 8,
            hPadding: 12
          )
        }
      } label: {
        Text("Birthday")
          .fromLabelStyle()
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
