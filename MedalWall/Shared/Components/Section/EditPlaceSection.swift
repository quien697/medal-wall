//
//  EditPlaceSection.swift
//  MedalWall
//
//  Created by Quien on 2026-08-05.
//

import SwiftUI

/// Place entry shared by the race and medal edit forms.
///
/// Place search is the only way to set a place.
///
/// The section reports the tap rather than presenting the picker itself. A `.sheet` attached
/// to a row inside a `Form` is torn down when the row is first realized, which dismisses the
/// sheet on the very first tap; the presenting view owns it instead, as
/// `EditRaceEditionSection` already does.
struct EditPlaceSection: View {
  let place: Place
  let onTap: () -> Void

  var body: some View {
    Section("Place") {
      Button(action: onTap) {
        LabeledContent {
          Text(place.formatted.isEmpty ? .appLocalized("Choose a place") : place.formatted)
            .multilineTextAlignment(.trailing)
            .foregroundStyle(place.formatted.isEmpty ? .secondary : .primary)
        } label: {
          Text("Place")
            .fromLabelStyle()
        }  // LabeledContent
      }  // Button
    }  // Section
  }
}

#Preview("Filled") {
  NavigationStack {
    Form {
      EditPlaceSection(place: Place(countryCode: "TW", city: "桃園市")) {}
      EditPlaceSection(place: Place(countryCode: "US", city: "Portland", region: "OR")) {}
    }
  }
}

#Preview("Empty") {
  NavigationStack {
    Form {
      EditPlaceSection(place: Place(countryCode: "", city: "")) {}
    }
  }
}
