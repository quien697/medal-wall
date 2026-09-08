//
//  MedalDetailFactsSection.swift
//  MedalWall
//
//  Created by Quien on 2026-09-08.
//

import SwiftUI

/// The fixed facts of a race — where, when, how far, under which bib.
///
/// Untitled by design: the rows label themselves, and a heading over four labelled rows
/// would name the same thing twice.
struct MedalDetailFactsSection: View {
  // MARK: - Properties
  let location: String
  let date: String
  let distance: String
  let raceType: String
  let bib: String

  // MARK: - Body
  var body: some View {
    VStack(spacing: 0) {
      MedalDetailFactRow(
        label: .appLocalized("Location"),
        value: location,
        secondaryValue: nil
      )

      hairline

      MedalDetailFactRow(
        label: .appLocalized("Date"),
        value: date,
        secondaryValue: nil
      )

      hairline

      MedalDetailFactRow(
        label: .appLocalized("Distance"),
        value: distance,
        secondaryValue: raceType
      )

      hairline

      MedalDetailFactRow(
        label: .appLocalized("Bib"),
        value: bib,
        secondaryValue: nil
      )
    }  // VStack
    .padding(.horizontal, .Space.gutter)
  }

  // MARK: - Subviews
  private var hairline: some View {
    Rectangle()
      .fill(Color.Border.primary)
      .frame(height: 1)
  }
}

#Preview {
  MedalDetailFactsSection(
    location: "Taipei City, TW",
    date: "Dec 15, 2019",
    distance: "Full · 42.2 km",
    raceType: "In-Person",
    bib: "00001"
  )
  .background(Color.Background.primary)
}
