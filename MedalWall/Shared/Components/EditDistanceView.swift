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
  @State private var draftDistance: RaceEvent
  /// The standard distance chosen, or `nil` while Custom is chosen. Kept apart from the
  /// custom number so typing `42.195` does not switch the row to Full Marathon mid-entry.
  @State private var selectedStandard: RaceDistanceCategory?
  @State private var customValue: Double
  @State private var customUnit: DistanceUnit
  @State private var errorWrapper: ErrorWrapper?

  // MARK: - Properties
  let mode: ItemEditMode
  let onAction: (RaceEvent) throws -> Void

  // MARK: - Init
  /// Opens a stored custom distance as its own number and unit. A new custom distance starts
  /// at the distance unit setting.
  init(
    mode: ItemEditMode,
    distance: RaceEvent,
    onAction: @escaping (RaceEvent) throws -> Void
  ) {
    let isStandard = distance.category.isStandard

    self.mode = mode
    self.draftDistance = distance
    self.selectedStandard = isStandard ? distance.category : nil
    self.customValue = isStandard ? 0 : distance.category.value
    self.customUnit = isStandard ? DistanceUnit.resolved() : distance.category.unit
    self.onAction = onAction
  }

  // MARK: - Computed
  /// A preset row showing its stored measurement, the same in both units, so a user looking
  /// for a number they know finds it here rather than typing it into Custom.
  private func presetRow(
    _ name: LocalizedStringKey,
    _ category: RaceDistanceCategory
  ) -> some View {
    HStack {
      Text(name)
        .font(.TypeScale.Field.label)

      Spacer()

      Text(category.unit.formatted(value: category.value))
        .font(.TypeScale.Field.value)
        .foregroundStyle(Color.Text.secondary)
    }  // HStack
    .tag(Optional(category))
  }

  // MARK: - Body
  var body: some View {
    NavigationStack {
      Form {
        Section("Distance") {
          Picker("Distance", selection: $selectedStandard) {
            presetRow("Full Marathon", .full)
            presetRow("Half Marathon", .half)
            presetRow("10K", .tenKM)
            presetRow("5K", .fiveKM)
            Text("Custom")
              .font(.TypeScale.Field.label)
              .tag(RaceDistanceCategory?.none)
          }  // Picker
          .pickerStyle(.navigationLink)

          if selectedStandard == nil {
            TextField("Custom distance", value: $customValue, format: .number)
              .font(.TypeScale.Field.value)
              .keyboardType(.decimalPad)

            Picker("Distance", selection: $customUnit) {
              ForEach(DistanceUnit.allCases, id: \.self) { unit in
                Text(unit.label).tag(unit)
              }
            }  // Picker
            .pickerStyle(.segmented)
          }
        }  // Section

        Section("Distance Type") {
          Picker("Distance Type", selection: $draftDistance.type) {
            ForEach(RaceDistanceType.allCases, id: \.self) { type in
              Text(type.displayName).tag(type)
            }
          }  // Picker
          .pickerStyle(.segmented)
        }  // Section
      }  // Form
      .navigationTitle("\(mode.displayName) Distance")
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(role: .close) {
            dismiss()
          }  // Button
        }  // ToolbarItem

        ToolbarItem(placement: .confirmationAction) {
          Button(role: .confirm) {
            var distance = draftDistance
            distance.category =
              selectedStandard ?? RaceDistanceCategory(value: customValue, unit: customUnit)
            do {
              try onAction(distance)
              dismiss()
            } catch let appError as AppError {
              errorWrapper = ErrorWrapper(error: appError)
            } catch {
              errorWrapper = ErrorWrapper(error: AppError.unknown)
            }
          }  // Button
        }  // ToolbarItem
      }  // toolbar
      .sheet(item: $errorWrapper) { wrapper in
        ErrorView(errorWrapper: wrapper)
      }
    }  // NavigationStack
  }
}

#Preview("New distance") {
  EditDistanceView(
    mode: .add,
    distance: .default,
    onAction: { _ in }
  )
}

#Preview("Stored custom distance in miles") {
  EditDistanceView(
    mode: .edit,
    distance: RaceEvent(
      category: RaceDistanceCategory(value: 26.2, unit: .miles), type: .inPerson),
    onAction: { _ in }
  )
}
