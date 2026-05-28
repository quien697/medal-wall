//
//  AddRaceEditionView.swift
//  MedalWall
//
//  Created by Quien on 2026-03-30.
//

import SwiftUI

struct AddRaceEditionView: View {
  let raceId: String

  var body: some View {
    EditRaceEditionView(mode: .add, raceId: raceId)
  }
}

#Preview {
  AddRaceEditionView(raceId: "preview-race-id")
    .environment(UserManager())
}
