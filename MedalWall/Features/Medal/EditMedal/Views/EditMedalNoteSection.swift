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
    Section("Notes") {
      TextField("Note", text: $note, axis: .vertical)
        .lineLimit(3...)
    } // Section
  }
}

#Preview {
  Form {
    EditMedalNoteSection(note: .constant(""))
    
    EditMedalNoteSection(note: .constant("This is the best marathon event ever"))
  }
}
