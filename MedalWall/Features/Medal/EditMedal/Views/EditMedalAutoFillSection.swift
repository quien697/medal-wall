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
            .font(.headline)
            .fontWeight(.bold)
          
          Text("Pick a race event to auto-fill fields")
            .font(.subheadline)
            .foregroundStyle(Color.Text.tertiary)
        }
        
        Spacer()
        
        Button {
          onAction()
        } label: {
          Text("Select")
        }
        .buttonStyle(.plain)
        .goldFillButtonStyle()
      } // HStack
    } // Section
    .listRowBackground(Color.Gold.primary.opacity(0.1))
  }
}

#Preview {
  EditMedalAutoFillSection(onAction: {})
}
