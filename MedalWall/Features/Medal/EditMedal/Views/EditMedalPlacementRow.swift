//
//  EditMedalPlacementRow.swift
//  MedalWall
//
//  Created by Quien on 2026-04-14.
//

import SwiftUI

struct EditMedalPlacementRow: View {
  let label: LocalizedStringKey
  @Binding var placement: Int?
  @Binding var total: Int?

  var body: some View {
    LabeledContent {
      HStack(spacing: 4) {
        TextField("Placement", value: $placement, format: .number)
          .fromStyle(.value)
          .keyboardType(.numberPad)
          .fixedSize()

        Text("of")
          .font(.TypeScale.caption)
          .foregroundStyle(Color.Text.tertiary)

        TextField("Total", value: $total, format: .number)
          .fromStyle(.value)
          .keyboardType(.numberPad)
          .fixedSize()
      }  // HStack
    } label: {
      Text(label)
        .fromStyle(.label)
    }  // LabeledContent
  }
}

#Preview {
  Form {
    EditMedalPlacementRow(
      label: "Overall",
      placement: .constant(nil),
      total: .constant(nil)
    )

    EditMedalPlacementRow(
      label: "Overall",
      placement: .constant(1928),
      total: .constant(5232)
    )
  }
}
