//
//  PlacePickerView.swift
//  MedalWall
//
//  Created by Quien on 2026-04-24.
//

import SwiftUI
import MapKit

struct PlacePickerView: View {
  @Binding var selectedPlace: Place?
  @Environment(\.dismiss) private var dismiss
  @State private var viewModel = PlaceSearchViewModel()

  var body: some View {
    NavigationStack {
      List {
        switch viewModel.status {
        case .searching:
          HStack {
            Spacer()
            ProgressView()
            Spacer()
          }
          .listRowBackground(Color.clear)

        case .result:
          ForEach(viewModel.results) { result in
            Button {
//              Task {
//                if let place = await viewModel.resolve(result) {
//                  selectedPlace = place
//                  dismiss()
//                }
//              }
            } label: {
              VStack(alignment: .leading, spacing: 4) {
                Text(result.title)
                  .foregroundStyle(.primary)
                if !result.subTitle.isEmpty {
                  Text(result.subTitle)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
              }
              .padding(.vertical, 2)
            }
            .buttonStyle(.plain)
          }

        case .error(let message):
          Text(message)
            .foregroundStyle(.secondary)
            .listRowBackground(Color.clear)

        case .idle:
          EmptyView()
        }
      }
      .searchable(
        text: $viewModel.query,
        placement: .navigationBarDrawer(displayMode: .always),
        prompt: "Search city or town"
      )
      .navigationTitle("Select Location")
      .navigationBarTitleDisplayMode(.inline)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") { dismiss() }
        }
      }
    }
  }
}

#Preview {
  @Previewable @State var place: Place? = nil

  PlacePickerView(selectedPlace: $place)
}
