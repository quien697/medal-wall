//
//  EditMedalTagsSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-19.
//

import SwiftUI

struct EditMedalTagsSection: View {
  @State private var input: String = ""
  let tags: [String]
  let onAdd: (String) -> Void
  let onRemove: (String) -> Void

  var body: some View {
    Section {
      FlowLayout(spacing: 8) {
        ForEach(tags, id: \.self) { tag in
          HStack(spacing: 4) {
            Text(tag)
            Button {
              onRemove(tag)
            } label: {
              Image(systemName: "xmark")
                .font(.TypeScale.overline)
            }  // Button
          }  // HStack
          .chipStyle(.neutral)
          .buttonStyle(.plain)
        }  // ForEach
      }  // FlowLayout

      HStack {
        TextField("Add tag", text: $input)
          .font(.TypeScale.Field.value)

        if !input.trimmingCharacters(in: .whitespaces).isEmpty {
          Button {
            onAdd(input)
            input = ""
          } label: {
            Image(systemName: "plus.circle.fill")
              .foregroundStyle(Color.Text.primary)
          }  // Button
          .buttonStyle(.plain)
        }
      }  // HStack
      .listRowSeparator(.hidden)
      .padding(8)
      .background(Color.Surface.secondary)
      .clipShape(.rect(cornerRadius: 8))
    } header: {
      Text("Tags")
        .sectionTitleStyle()
    }  // Section
  }
}

#Preview {
  Form {
    EditMedalTagsSection(
      tags: ["marathon", "taipei", "2026"],
      onAdd: { _ in },
      onRemove: { _ in }
    )
  }
}
