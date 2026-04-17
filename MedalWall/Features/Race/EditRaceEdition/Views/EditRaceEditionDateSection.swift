//
//  EditRaceEditionDateSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-30.
//

import SwiftUI

struct EditRaceEditionDateSection: View {
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
  
  var body: some View {
    Section("Date") {
      Toggle(isOn: Binding(
        get: { isOneDay },
        set: { _ in onToggleOneDay() }
      )) {
        Text("One Day Event")
          .fromLabelStyle()
      }

      Picker(selection: Binding(
        get: { year },
        set: { onUpdateYear($0) }
      )) {
        ForEach((minYear...maxYear).reversed(), id: \.self) { year in
          Text(String(year))
            .font(.body)
            .tag(year)
        }
      } label: {
        Text("Year")
          .fromLabelStyle()
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
          .fromLabelStyle()
      }

      if !isOneDay {
        DatePicker(
          selection: $endDate,
          in: minEndDate...maxEndDate,
          displayedComponents: [.date]
        ) {
          Text("End Date")
            .fromLabelStyle()
        }
      }
    } // Section
  }
}

#Preview {
  Form {
    EditRaceEditionDateSection(
      isOneDay: true,
      year: .constant(2026),
      startDate: .constant(Date()),
      endDate: .constant(Date()),
      minYear: 1911,
      maxYear: 2060,
      yearDateRange: Date()...Date(),
      minEndDate: Date(),
      maxEndDate: Date(),
      onToggleOneDay: {},
      onUpdateYear: { _ in },
      onUpdateStartDate: { _ in }
    )
    
    EditRaceEditionDateSection(
      isOneDay: false,
      year: .constant(2026),
      startDate: .constant(Date()),
      endDate: .constant(Date()),
      minYear: 1911,
      maxYear: 2060,
      yearDateRange: Date()...Date(),
      minEndDate: Date(),
      maxEndDate: Date(),
      onToggleOneDay: {},
      onUpdateYear: { _ in },
      onUpdateStartDate: { _ in }
    )
  }
}
