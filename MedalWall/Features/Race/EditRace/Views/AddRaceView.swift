//
//  AddRaceView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-05.
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
