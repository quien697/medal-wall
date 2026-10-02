//
//  AddMedalView.swift
//  MedalWall
//
//  Created by Quien on 2026-10-02.
//

import SwiftUI

struct AddMedalView: View {
  var body: some View {
    EditMedalView(mode: .add)
  }
}

#Preview {
  AddMedalView()
    .environment(UserManager())
}
