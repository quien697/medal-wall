//
//  RaceEditionEditDateSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-30.
//

import SwiftUI

struct RaceEditionEditDateSection: View {
  let isOneDay: Bool
  @Binding var year: Int
  @Binding var startDate: Date
  @Binding var endDate: Date
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
          .fontWeight(.bold)
          .foregroundStyle(Color.Text.tertiary)
      }
      .tint(Color.Badge.Gold.primary)
      
      Picker(selection: Binding(
        get: { year },
        set: { onUpdateYear($0) }
      )) {
        ForEach((1911...2090).reversed(), id: \.self) { year in
          Text(String(year))
            .font(.body)
            .tag(year)
        }
      } label: {
        Text("Year")
          .fontWeight(.bold)
          .foregroundStyle(Color.Text.tertiary)
      }
      .tint(Color.Text.primary)
      
      DatePicker(
        selection: Binding(
          get: { startDate },
          set: { onUpdateStartDate($0) }
        ),
        in: yearDateRange,
        displayedComponents: [.date]
      ) {
        Text("Start Date")
          .fontWeight(.bold)
          .foregroundStyle(Color.Text.tertiary)
      }
      .tint(Color.Badge.Gold.primary)
      
      if !isOneDay {
        DatePicker(
          selection: $endDate,
          in: minEndDate...maxEndDate,
          displayedComponents: [.date]
        ) {
          Text("End Date")
            .fontWeight(.bold)
            .foregroundStyle(Color.Text.tertiary)
        }
        .tint(Color.Badge.Gold.primary)
      }
    } // Section
  }
}

#Preview {
  Form {
    RaceEditionEditDateSection(
      isOneDay: true,
      year: .constant(2026),
      startDate: .constant(Date()),
      endDate: .constant(Date()),
      yearDateRange: Date()...Date(),
      minEndDate: Date(),
      maxEndDate: Date(),
      onToggleOneDay: {},
      onUpdateYear: { _ in },
      onUpdateStartDate: { _ in }
    )
    
    RaceEditionEditDateSection(
      isOneDay: false,
      year: .constant(2026),
      startDate: .constant(Date()),
      endDate: .constant(Date()),
      yearDateRange: Date()...Date(),
      minEndDate: Date(),
      maxEndDate: Date(),
      onToggleOneDay: {},
      onUpdateYear: { _ in },
      onUpdateStartDate: { _ in }
    )
  }
}
