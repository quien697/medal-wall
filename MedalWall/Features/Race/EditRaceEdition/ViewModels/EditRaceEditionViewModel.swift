//
//  EditRaceEditionViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-03-26.
//

import SwiftUI
import SwiftData

@Observable
final class EditRaceEditionViewModel {
  let minYear: Int = 1911
  let maxYear: Int = 2060
  var draftEdition: DraftRaceEdition
  let mode: ItemEditMode
  
  init(mode: ItemEditMode, edition: DraftRaceEdition?) {
    self.mode = mode
    self.draftEdition = edition ?? DraftRaceEdition()
  }
  
  var isFormValid: Bool {
    draftEdition.year >= minYear &&
    draftEdition.year <= maxYear &&
    draftEdition.startDate <= draftEdition.endDate
  }
  
  var yearDateRange: ClosedRange<Date> {
    let calendar = Calendar.current
    let startOfYear = calendar.date(from: DateComponents(year: draftEdition.year, month: 1, day: 1)) ?? Date()
    let endOfYear = calendar.date(from: DateComponents(year: draftEdition.year, month: 12, day: 31)) ?? Date()
    
    return startOfYear...endOfYear
  }
  
  var minEndDate: Date {
    draftEdition.startDate
  }
  
  var maxEndDate: Date {
    return Calendar.current.date(from: DateComponents(year: draftEdition.year, month: 12, day: 31)) ?? Date()
  }
  
  func updatePhoto(with uiImage: UIImage) {
    draftEdition.photoData = uiImage.pngData()
  }
  
  func clearPhoto() {
    draftEdition.photoData = nil
  }
  
  func toggleOneDay() {
    draftEdition.isOneDay.toggle()
    
    if draftEdition.isOneDay {
      draftEdition.endDate = draftEdition.startDate
    }
  }
  
  func updateYear(_ newYear: Int) {
    draftEdition.year = newYear
    let startOfYear = Calendar.current.date(from: DateComponents(year: newYear, month: 1, day: 1)) ?? Date()
    let endOfYear = Calendar.current.date(from: DateComponents(year: newYear, month: 12, day: 31)) ?? Date()
    
    if draftEdition.startDate < startOfYear || draftEdition.startDate > endOfYear {
      draftEdition.startDate = startOfYear
    }
    
    if draftEdition.endDate < draftEdition.startDate || draftEdition.endDate > endOfYear {
      draftEdition.endDate = draftEdition.isOneDay ? draftEdition.startDate : endOfYear
    }
  }
  
  func updateStartDate(_ newStartDate: Date) {
    draftEdition.startDate = newStartDate
    
    if draftEdition.isOneDay {
      draftEdition.endDate = newStartDate
    } else {
      if draftEdition.endDate < newStartDate {
        draftEdition.endDate = newStartDate
      }
    }
  }
  
  func addDistance(_ distance: RaceDistance) throws {
    guard !draftEdition.distances.contains(distance) else {
      throw AppError.duplicateDistance
    }
    
    draftEdition.distances.append(distance)
  }
  
  func removeDistance(_ distance: RaceDistance) {
    draftEdition.distances.removeAll { $0 == distance }
  }
}
