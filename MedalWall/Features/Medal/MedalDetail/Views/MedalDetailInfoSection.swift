//
//  MedalDetailInfoSection.swift
//  MedalWall
//
//  Created by Quien on 2026-09-08.
//

import SwiftUI

/// The fixed facts of a race — where, when, how far, under which bib.
///
/// Untitled by design: the rows label themselves, and a heading over four labelled rows
/// would name the same thing twice.
struct MedalDetailInfoSection: View {
  // MARK: - Properties
  let location: String
  let date: String
  let distance: String
  let raceType: String
  let bib: String

  // MARK: - Body
  var body: some View {
    PageSection(spacing: 0) {
      MedalDetailInfoRow(
        label: .appLocalized("Location"),
        value: location,
        secondaryValue: nil
      )

      Divider()

      MedalDetailInfoRow(
        label: .appLocalized("Date"),
        value: date,
        secondaryValue: nil
      )

      Divider()

      MedalDetailInfoRow(
        label: .appLocalized("Distance"),
        value: distance,
        secondaryValue: raceType
      )

      Divider()

      MedalDetailInfoRow(
        label: .appLocalized("Bib"),
        value: bib,
        secondaryValue: nil
      )
    }  // PageSection
  }
}

#Preview {
  MedalDetailInfoSection(
    location: "Taipei City, TW",
    date: "Dec 15, 2019",
    distance: "Full · 42.2 km",
    raceType: "In-Person",
    bib: "00001"
  )
  .background(Color.Background.primary)
}
