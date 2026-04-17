//
//  AddRaceEditionView.swift
//  MedalWall
//
//  Created by Quien on 2026-03-30.
//

import SwiftUI

struct AddRaceEditionView: View {
  let onAction: (DraftRaceEdition) -> Void
  
  var body: some View {
    EditRaceEditionView(
      mode: .add,
      onAction: onAction
    )
  }
}

#Preview {
  AddRaceEditionView(onAction: { _ in })
}
