//
//  EditRaceEditionDateSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-30.
//

import SwiftUI

struct EditRaceEditionDateSection: View {
  // MARK: - Properties
  let isOneDay: Bool
  @Binding var year: Int
  @Binding var startDate: Date
  @Binding var endDate: Date
  let minYear: Int
  let maxYear: Int
  let yearDateRange: ClosedRange<Date>
  let minEndDate: Date
  let maxEndDate: Date
  var onToggleOneDay: () -> Void
  var onUpdateYear: (Int) -> Void
  var onUpdateStartDate: (Date) -> Void

  // MARK: - Body
  var body: some View {
    Section("Date") {
      Toggle(
        isOn: Binding(
          get: { isOneDay },
          set: { _ in onToggleOneDay() }
        )
      ) {
        Text("One Day Event")
          .fromStyle(.label)
      }

      Picker(
        selection: Binding(
          get: { year },
          set: { onUpdateYear($0) }
        )
      ) {
        ForEach((minYear...maxYear).reversed(), id: \.self) { year in
          Text(String(year))
            .font(.TypeScale.body)
            .tag(year)
        }
      } label: {
        Text("Year")
          .fromStyle(.label)
      }

      DatePicker(
        selection: Binding(
          get: { startDate },
          set: { onUpdateStartDate($0) }
        ),
        in: yearDateRange,
        displayedComponents: [.date]
      ) {
        Text("Start Date")
          .fromStyle(.label)
      }

      if !isOneDay {
        DatePicker(
          selection: $endDate,
          in: minEndDate...maxEndDate,
          displayedComponents: [.date]
        ) {
          Text("End Date")
            .fromStyle(.label)
        }
      }
    }  // Section
  }
}

#Preview {
  let calendar = Calendar.current
  let jan1 = calendar.date(from: DateComponents(year: 2026, month: 1, day: 1))!
  let jun15 = calendar.date(from: DateComponents(year: 2026, month: 6, day: 15))!
  let dec31 = calendar.date(from: DateComponents(year: 2026, month: 12, day: 31))!
  let yearRange = jan1...dec31

  Form {
    EditRaceEditionDateSection(
      isOneDay: true,
      year: .constant(2026),
      startDate: .constant(jan1),
      endDate: .constant(jan1),
      minYear: 1911,
      maxYear: 2060,
      yearDateRange: yearRange,
      minEndDate: jan1,
      maxEndDate: dec31,
      onToggleOneDay: {},
      onUpdateYear: { _ in },
      onUpdateStartDate: { _ in }
    )

    EditRaceEditionDateSection(
      isOneDay: false,
      year: .constant(2026),
      startDate: .constant(jan1),
      endDate: .constant(jun15),
      minYear: 1911,
      maxYear: 2060,
      yearDateRange: yearRange,
      minEndDate: jan1,
      maxEndDate: dec31,
      onToggleOneDay: {},
      onUpdateYear: { _ in },
      onUpdateStartDate: { _ in }
    )
  }
}
