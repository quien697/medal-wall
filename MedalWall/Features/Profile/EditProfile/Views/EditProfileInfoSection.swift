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
        if isBirthdaySet {
          HStack {
            Button {
              isBirthdaySet = false
              birthday = .now
            } label: {
              Image(systemName: "xmark")
            }
            .actionStyle(
              .neutral,
              font: .TypeScale.caption,
              vPadding: 6,
              hPadding: 6
            )

            DatePicker("", selection: $birthday, displayedComponents: .date)
              .labelsHidden()
          }
        } else {
          Button("Not Set") {
            isBirthdaySet = true
          }
          .actionStyle(
            .neutral,
            font: .TypeScale.Field.button,
            vPadding: 6,
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
