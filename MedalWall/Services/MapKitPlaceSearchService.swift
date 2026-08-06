//
//  MapKitPlaceSearchService.swift
//  MedalWall
//
//  Created by Quien on 2026-08-05.
//

import Foundation
import MapKit

/// Supplies place suggestions for a search query and resolves a chosen one into a
/// `Place`.
///
/// The protocol exists so the picker can be tested without a network or a map framework:
/// `MapKitPlaceSearchService` is the only implementation that talks to MapKit.
@MainActor
protocol PlaceSearchService {
  /// Streams suggestions for `query`, emitting a new array each time results arrive.
  /// Starting a new search finishes the previous stream.
  ///
  /// A query that simply matches nothing yields an empty array; the stream only fails when
  /// the search itself does, so "no results" and "search broke" stay distinguishable.
  /// - Throws: `AppError.placeSearchFailed` when the search fails.
  func suggestions(for query: String) -> AsyncThrowingStream<[PlaceSuggestion], any Error>

  /// Resolves a suggestion into a complete place.
  /// - Throws: `AppError.placeNotResolved` when the suggestion is unknown or has no result,
  ///   or `AppError.placeSearchFailed` when the lookup itself fails.
  func resolve(suggestionID: PlaceSuggestion.ID) async throws -> Place
}

// MARK: - MapKit implementation
/// `PlaceSearchService` backed by MapKit.
///
/// **This is the only file in the app that imports MapKit**, and MapKit types never
/// leave it: completions are retained internally and callers see only
/// `PlaceSuggestion` and `Place`. The containment is deliberate. The structured
/// address fields read here are soft-deprecated on iOS 26 — the modern replacements return
/// display strings with no `locality` equivalent — so when Apple removes them, only this
/// file changes. The stored Firestore shape, and any other client platform reading it, is
/// untouched by that.
@MainActor
final class MapKitPlaceSearchService: NSObject, PlaceSearchService {
  // MARK: - State
  private let completer = MKLocalSearchCompleter()
  private var completionsByID: [PlaceSuggestion.ID: MKLocalSearchCompletion] = [:]
  private var continuation: AsyncThrowingStream<[PlaceSuggestion], any Error>.Continuation?

  // MARK: - Init
  override init() {
    super.init()
    completer.delegate = self
    // Places are recorded at city level, so points of interest are noise: searching
    // "Taipei" should offer the city, not its restaurants.
    completer.resultTypes = [.address]
    completer.pointOfInterestFilter = .excludingAll
  }

  // MARK: - Functions
  func suggestions(for query: String) -> AsyncThrowingStream<[PlaceSuggestion], any Error> {
    let (stream, continuation) = AsyncThrowingStream<[PlaceSuggestion], any Error>.makeStream()
    self.continuation?.finish()
    self.continuation = continuation

    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    if trimmed.isEmpty {
      completionsByID = [:]
      continuation.yield([])
    } else {
      completer.queryFragment = trimmed
    }

    return stream
  }

  func resolve(suggestionID: PlaceSuggestion.ID) async throws -> Place {
    guard let completion = completionsByID[suggestionID] else {
      throw AppError.placeNotResolved
    }

    let response: MKLocalSearch.Response
    do {
      response = try await MKLocalSearch(request: .init(completion: completion)).start()
    } catch {
      throw AppError.placeSearchFailed(error.localizedDescription)
    }

    guard let item = response.mapItems.first else {
      throw AppError.placeNotResolved
    }
    return Self.place(from: item)
  }

  private static func place(from item: MKMapItem) -> Place {
    let placemark = item.placemark
    return place(
      isoCountryCode: placemark.isoCountryCode,
      administrativeArea: placemark.administrativeArea,
      subAdministrativeArea: placemark.subAdministrativeArea,
      locality: placemark.locality
    )
  }

  /// Normalizes a provider's administrative fields to **city level**.
  ///
  /// `locality` and `administrativeArea` do not mean the same thing everywhere. In the US
  /// and Canada `locality` is the city and `administrativeArea` the state or province. In
  /// Taiwan they are inverted: `administrativeArea` holds the city or county (桃園市, 彰化縣)
  /// and `locality` holds a district or township below it (復興區, 田中鎮).
  ///
  /// `subAdministrativeArea == administrativeArea` is the observed signal for that inversion
  /// — true throughout Taiwan, false in the US, Canada, and Japan. When it holds, the
  /// administrative area *is* the city, so it is promoted and the sub-unit dropped. An
  /// absent `locality` is treated the same way, which is what makes a bare "Tokyo" or
  /// "Taipei" resolvable rather than yielding an empty city.
  ///
  /// Taken as strings rather than an `MKMapItem` so the rule can be unit tested without a
  /// network round-trip.
  static func place(
    isoCountryCode: String?,
    administrativeArea: String?,
    subAdministrativeArea: String?,
    locality: String?
  ) -> Place {
    let countryCode = isoCountryCode ?? ""

    let area = administrativeArea ?? ""
    let sublocality = locality ?? ""
    let areaIsTheCity = sublocality.isEmpty || subAdministrativeArea == administrativeArea

    let city = areaIsTheCity ? area : sublocality
    var region: String? = areaIsTheCity ? nil : area

    // A region that merely repeats the city, or restates the country code as Singapore's
    // does, adds nothing to the display line.
    if region == city || region == countryCode || region?.isEmpty == true {
      region = nil
    }

    return Place(countryCode: countryCode, city: city, region: region)
  }
}

// MARK: - MKLocalSearchCompleterDelegate
extension MapKitPlaceSearchService: MKLocalSearchCompleterDelegate {
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    var completions: [PlaceSuggestion.ID: MKLocalSearchCompletion] = [:]
    var suggestions: [PlaceSuggestion] = []

    for (index, completion) in completer.results.enumerated() {
      let id = "\(index)-\(completion.title)-\(completion.subtitle)"
      completions[id] = completion
      suggestions.append(
        PlaceSuggestion(id: id, title: completion.title, subtitle: completion.subtitle))
    }

    completionsByID = completions
    continuation?.yield(suggestions)
  }

  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
    // A query that matches nothing is an empty result, not a failure.
    if (error as? MKError)?.code == .placemarkNotFound {
      completionsByID = [:]
      continuation?.yield([])
      return
    }

    continuation?.finish(throwing: AppError.placeSearchFailed(error.localizedDescription))
  }
}
