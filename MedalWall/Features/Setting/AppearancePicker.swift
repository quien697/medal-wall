//
//  AppearancePicker.swift
//  MedalWall
//
//  Created by Quien on 2026-04-20.
//

import SwiftUI

struct AppearancePicker: View {
  @Binding var appTheme: AppTheme

  var body: some View {
    Picker(selection: $appTheme) {
      ForEach(AppTheme.allCases, id: \.self) { theme in
        HStack {
          Image(systemName: theme.icon)

          Text(theme.label)
            .font(.TypeScale.Field.value)
        }  // HStack
        .tag(theme)
      }  // ForEach
    } label: {
      Text("Appearance")
        .font(.TypeScale.Field.label)
    }  // Picker
    .pickerStyle(.navigationLink)
  }
}

#Preview {
  NavigationStack {
    AppearancePicker(appTheme: .constant(.dark))
  }
}
