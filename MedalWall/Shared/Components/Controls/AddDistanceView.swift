//
//  AddDistanceView.swift
//  MedalWall
//
//  Created by Quien on 2026-04-15.
//

import SwiftUI

struct AddDistanceView: View {
  let onSave: (RaceDistance) -> Void

  var body: some View {
    EditDistanceView(
      mode: .add,
      distance: .default,
      onAction: onSave
    )
  }
}

#Preview {
  AddDistanceView(onSave: { _ in })
}
