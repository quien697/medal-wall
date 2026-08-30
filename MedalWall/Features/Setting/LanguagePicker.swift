//
//  LanguagePicker.swift
//  MedalWall
//
//  Created by Quien on 2026-08-11.
//

import SwiftUI

struct LanguagePicker: View {
  @Binding var appLanguage: AppLanguage

  var body: some View {
    Picker(selection: $appLanguage) {
      ForEach(AppLanguage.allCases, id: \.self) { language in
        Text(language.label)
          .font(.TypeScale.Field.value)
          .tag(language)
      }  // ForEach
    } label: {
      Text("Language")
        .font(.TypeScale.Field.label)
    }  // Picker
    .pickerStyle(.navigationLink)
  }
}

#Preview("System") {
  NavigationStack {
    LanguagePicker(appLanguage: .constant(.system))
  }
}

#Preview("繁體中文") {
  NavigationStack {
    LanguagePicker(appLanguage: .constant(.zhTW))
  }
}
