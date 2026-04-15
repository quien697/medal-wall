//
//  DistanceAddView.swift
//  MedalWall
//
//  Created by Quien on 2026-04-15.
//

import SwiftUI

struct DistanceAddView: View {
  let onSave: (RaceDistance) -> Void
  
  var body: some View {
    DistanceEditView(
      mode: .add,
      distance: .default,
      onAction: onSave
    )
  }
}

#Preview {
  DistanceAddView(onSave: { _ in print("onSave") })
}
