//
//  EditMedalTagsSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-19.
//

import SwiftUI

struct EditMedalTagsSection: View {
  @Binding var tags: [String]
  @State private var input: String = ""

  var body: some View {
    Section("Tags") {
      FlowLayout(spacing: 8) {
        ForEach(tags, id: \.self) { tag in
          HStack(spacing: 4) {
            Text(tag)
            Button {
              tags.removeAll { $0 == tag }
            } label: {
              Image(systemName: "xmark")
                .font(.caption2)
                .fontWeight(.bold)
            }
          }
          .tagStyle(.neutral)
          .buttonStyle(.plain)
        }  // ForEach
      }  // FlowLayout

      HStack {
        TextField("Add tag", text: $input)

        if !input.trimmingCharacters(in: .whitespaces).isEmpty {
          Button {
            let trimmed = input.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !tags.contains(trimmed) else {
              input = ""
              return
            }

            tags.append(trimmed)
            input = ""
          } label: {
            Image(systemName: "plus.circle.fill")
              .foregroundStyle(Color.Gold.primary)
          }
          .buttonStyle(.plain)
        }
      }  // HStack
      .listRowSeparator(.hidden)
      .padding(8)
      .background(Color.Card.Background.secondary)
      .clipShape(.rect(cornerRadius: 8))
    }  // Section
  }
}

#Preview {
  Form {
    EditMedalTagsSection(tags: .constant(["marathon", "taipei", "2026"]))
  }
}
