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
      ForEach(AppTheme.allCases, id: \.self) { scheme in
        HStack {
          Image(systemName: scheme.icon)

          Text(scheme.label)
            .font(.TypeScale.Field.value)
        }  // HStack
        .tag(scheme)
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
