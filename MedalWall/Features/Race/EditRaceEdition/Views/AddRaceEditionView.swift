//
//  AddRaceEditionView.swift
//  MedalWall
//
//  Created by Quien on 2026-10-02.
//

import SwiftUI

struct AddRaceEditionView: View {
  let onCommit: (DraftRaceEdition) -> Void

  var body: some View {
    EditRaceEditionView(onCommit: onCommit)
  }
}

#Preview {
  AddRaceEditionView(onCommit: { _ in })
    .environment(UserManager())
}
