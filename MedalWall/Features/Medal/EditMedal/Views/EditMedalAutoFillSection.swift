//
//  EditMedalAutoFillSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-14.
//

import SwiftUI

struct EditMedalAutoFillSection: View {
  let onAction: () -> Void

  var body: some View {
    Section {
      HStack {
        VStack(alignment: .leading) {
          Text("Fill from race event")
            .font(.TypeScale.headline)
            .foregroundStyle(Color.Text.primary)

          Text("Pick a race event to auto-fill fields")
            .font(.TypeScale.caption)
            .foregroundStyle(Color.Text.tertiary)
        }  // VStack

        Spacer()

        Button {
          onAction()
        } label: {
          Text("Select")
        }  // Button
        .buttonStyle(.plain)
        .actionStyle(.tertiary)
      }  // HStack
    }  // Section
  }
}

#Preview {
  EditMedalAutoFillSection(onAction: {})
}
