//
//  EditMedalNoteSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-14.
//

import SwiftUI

struct EditMedalNoteSection: View {
  @Binding var note: String

  var body: some View {
    Section {
      TextEditor(text: $note)
        .font(.TypeScale.body)
        .frame(minHeight: 100)
    } header: {
      Text("Notes")
        .sectionTitleStyle()
    }  // Section
  }
}

#Preview {
  Form {
    EditMedalNoteSection(note: .constant(""))

    EditMedalNoteSection(note: .constant("This is the best marathon event ever"))
  }
}
