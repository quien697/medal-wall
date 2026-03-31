//
//  RaceEditionEditViewModel.swift
//  MedalWall
//
//  Created by Quien on 2026-03-26.
//

import SwiftUI
import SwiftData

@Observable
final class RaceEditionEditViewModel {
  var draftEdition: DraftRaceEdition
  let mode: RaceEditionEditMode
  
  init(mode: RaceEditionEditMode, edition: DraftRaceEdition?) {
    self.mode = mode
    self.draftEdition = edition ?? DraftRaceEdition()
  }
  
  var isFormValid: Bool {
    draftEdition.year >= 1911 &&
    draftEdition.year <= 2090 &&
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
  
  func updatePhoto(with data: Data?) {
    draftEdition.photoData = data
  }
  
  func updateCropPhoto(with uiImage: UIImage) {
    draftEdition.cropPhotoData = uiImage.pngData()
  }
  
  func clearPhoto() {
    draftEdition.photoData = nil
    draftEdition.cropPhotoData = nil
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
