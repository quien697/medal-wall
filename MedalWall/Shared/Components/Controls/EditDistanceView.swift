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
  /// The active unit. `customValue` is expressed in it; `draftDistance.category` is always
  /// kilometre-canonical, and the two are bridged only through `DistanceUnit`.
  private let unit: DistanceUnit
  /// The kilometres this distance was opened with, so an unedited field saves unchanged.
  private let originalCustomKilometers: Double?

  // MARK: - Init
  init(
    mode: ItemEditMode,
    distance: RaceDistance,
    onAction: @escaping (RaceDistance) throws -> Void
  ) {
    let unit = DistanceUnit.resolved()
    let originalCustomKilometers: Double? = {
      if case .custom(let value) = distance.category { return value }
      return nil
    }()

    self.mode = mode
    self.draftDistance = distance
    self.unit = unit
    self.originalCustomKilometers = originalCustomKilometers
    self.customValue = originalCustomKilometers.map(unit.roundedDisplayValue) ?? 0
    self.onAction = onAction
  }

  // MARK: - Computed
  /// The field's value converted back to canonical kilometres, preserving the original
  /// when the field has not been edited.
  private var customKilometers: Double {
    unit.customKilometers(
      displayValue: customValue,
      originalKilometers: originalCustomKilometers
    )
  }

  /// A preset row showing its measurement in the active unit, so a user looking for a
  /// number they know finds it here rather than typing it into Custom.
  private func presetRow(
    _ name: LocalizedStringKey,
    _ category: RaceDistanceCategory
  ) -> some View {
    HStack {
      Text(name)

      Spacer()

      Text(unit.formatted(kilometers: category.value))
        .foregroundStyle(Color.Text.secondary)
    }  // HStack
    .tag(category)
  }

  // MARK: - Body
  var body: some View {
    NavigationStack {
      Form {
        Section("Distance") {
          Picker("Distance", selection: $draftDistance.category) {
            presetRow("Full Marathon", .full)
            presetRow("Half Marathon", .half)
            presetRow("10K", .tenKM)
            presetRow("5K", .fiveKM)
            Text("Custom").tag(RaceDistanceCategory.custom(customKilometers))
          }
          .pickerStyle(.navigationLink)

          if case .custom = draftDistance.category {
            TextField(unit.customFieldLabel(), value: $customValue, format: .number)
              .keyboardType(.decimalPad)
              .onChange(of: customValue) { _, _ in
                draftDistance.category = .custom(customKilometers)
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
