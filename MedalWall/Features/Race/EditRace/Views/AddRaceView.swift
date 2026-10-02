//
//  AddRaceView.swift
//  MedalWall
//
//  Created by Quien on 2026-10-02.
//

import SwiftUI

struct AddRaceView: View {
  var body: some View {
    EditRaceView(mode: .add)
  }
}

#Preview {
  AddRaceView()
    .environment(UserManager())
}
