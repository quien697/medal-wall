//
//  PlaceSearchViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-04-24.
//

import MapKit

@Observable
final class PlaceSearchViewModel: NSObject {
  
  var query: String = "" {
    didSet { handleSearchFragment(query) }
  }
  
  var results: [PlaceResult] = []
  var status: PlaceSearchStatus = .idle
  var completer: MKLocalSearchCompleter
  
  init(
    filter: MKPointOfInterestFilter = .excludingAll,
    region: MKCoordinateRegion = MKCoordinateRegion(.world),
    types: MKLocalSearchCompleter.ResultType = [.pointOfInterest, .query, .address]
  ) {
    completer = MKLocalSearchCompleter()
    super.init()
    
    completer.delegate = self
    completer.pointOfInterestFilter = filter
    completer.region = region
    completer.resultTypes = types
  }
  
  private func handleSearchFragment(_ fragment: String) {
    self.status = .searching
    
    if fragment.isEmpty {
      self.status = .idle
      self.results = []
    } else {
      self.completer.queryFragment = fragment
    }
  }
}

extension PlaceSearchViewModel: MKLocalSearchCompleterDelegate {
  
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    self.results = completer.results.map({ result in
      PlaceResult(title: result.title, subTitle: result.description)
    })
    
    self.status = .result
  }
  
  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
    self.status = .error(error.localizedDescription)
  }
}
