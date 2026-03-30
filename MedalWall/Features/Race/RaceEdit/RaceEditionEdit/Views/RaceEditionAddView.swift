//
//  RaceEditionAddView.swift
//  MedalWall
//
//  Created by Quien on 2026-03-30.
//

import SwiftUI

struct RaceEditionAddView: View {
  let onAction: (DraftRaceEdition) -> Void
  
  var body: some View {
    RaceEditionEditView(
      mode: .add,
      edition: nil,
      onAction: onAction
    )
  }
}

#Preview {
  RaceEditionAddView(onAction: { _ in })
}
