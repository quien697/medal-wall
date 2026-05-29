//
//  EditDistanceView.swift
//  MedalWall
//
//  Created by Quien on 2025-11-08.
//

import SwiftUI

struct EditDistanceView: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss

  // MARK: - State
  @State private var draftDistance: RaceDistance
  @State private var customValue: Double
  @State private var errorWrapper: ErrorWrapper?

  // MARK: - Properties
  let mode: ItemEditMode
  let onAction: (RaceDistance) throws -> Void

  // MARK: - Init
  init(
    mode: ItemEditMode,
    distance: RaceDistance,
    onAction: @escaping (RaceDistance) throws -> Void
  ) {
    self.mode = mode
    self.draftDistance = distance
    self.customValue = {
      if case .custom(let value) = distance.category { return value }
      return 0
    }()
    self.onAction = onAction
  }

  // MARK: - Body
  var body: some View {
    NavigationStack {
      Form {
        Section("Distance") {
          Picker("Distance", selection: $draftDistance.category) {
            Text("Full Marathon").tag(RaceDistanceCategory.full)
            Text("Half Marathon").tag(RaceDistanceCategory.half)
            Text("10K").tag(RaceDistanceCategory.tenKM)
            Text("5K").tag(RaceDistanceCategory.fiveKM)
            Text("Custom").tag(RaceDistanceCategory.custom(customValue))
          }
          .pickerStyle(.navigationLink)

          if case .custom = draftDistance.category {
            TextField("Custom distance (km)", value: $customValue, format: .number)
              .keyboardType(.decimalPad)
              .onChange(of: customValue) { _, newValue in
                draftDistance.category = .custom(newValue)
              }
          }
        }  // Section

        Section("Distance Type") {
          Picker("Distance Type", selection: $draftDistance.type) {
            ForEach(RaceDistanceType.allCases, id: \.self) { type in
              Text(type.displayName).tag(type)
            }
          }
          .pickerStyle(.segmented)
        }  // Section
      }  // Form
      .navigationTitle("\(mode.displayName) Distance")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(role: .close) {
            dismiss()
          }
        }

        ToolbarItem(placement: .confirmationAction) {
          Button(role: .confirm) {
            do {
              try onAction(draftDistance)
              dismiss()
            } catch let appError as AppError {
              errorWrapper = ErrorWrapper(error: appError)
            } catch {
              errorWrapper = ErrorWrapper(error: AppError.unknown)
            }
          }
        }
      }  // toolbar
      .sheet(item: $errorWrapper) { wrapper in
        ErrorView(errorWrapper: wrapper)
      }
    }  // NavigationStack
  }
}

#Preview {
  EditDistanceView(
    mode: .add,
    distance: RaceDistance(category: .half, type: .inPerson),
    onAction: { _ in }
  )
}
