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
  var year: Int
  var isOneDay: Bool
  var startDate: Date
  var endDate: Date
  var photoData: Data? = nil
  var photo: UIImage? = nil
  var cropPhotoData: Data? = nil
  var cropPhoto: UIImage? = nil
  var distances: [RaceDistance] = []
  
  let mode: RaceEditionEditMode
  private(set) var race: Race
  private(set) var edition: RaceEdition?
  
  init(mode: RaceEditionEditMode, race: Race, edition: RaceEdition?) {
    self.mode = mode
    self.race = race
    self.edition = edition
    
    if let edition {
      self.year = edition.year
      self.startDate = edition.startDate
      self.endDate = edition.endDate
      self.isOneDay = edition.isOneDay
      self.photoData = edition.photoData
      self.photo = edition.photo
      self.cropPhotoData = edition.cropPhotoData
      self.cropPhoto = edition.cropPhoto
      self.distances = edition.distances
    } else {
      // Default edition
      let currentYear = Calendar.current.component(.year, from: Date())
      self.year = currentYear
      self.isOneDay = true
      self.startDate = Date()
      self.endDate = Date()
    }
  }
  
  var isFormValid: Bool {
    year >= 1911 && year <= 2090 && !distances.isEmpty && startDate <= endDate
  }
  
  var yearDateRange: ClosedRange<Date> {
    let calendar = Calendar.current
    let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)) ?? Date()
    let endOfYear = calendar.date(from: DateComponents(year: year, month: 12, day: 31)) ?? Date()
    return startOfYear...endOfYear
  }
  
  var minEndDate: Date {
    startDate
  }
  
  var maxEndDate: Date {
    return Calendar.current.date(from: DateComponents(year: year, month: 12, day: 31)) ?? Date()
  }
  
  func updatePhoto(with data: Data?) {
    self.photoData = data
    
    if let data {
      self.photo = UIImage(data: data)
    } else {
      self.photo = nil
    }
  }
  
  func updateCropPhoto(with uiImage: UIImage) {
    self.cropPhotoData = uiImage.pngData()
    self.cropPhoto = uiImage
  }
  
  func clearPhoto() {
    self.photoData = nil
    self.photo = nil
    self.cropPhotoData = nil
    self.cropPhoto = nil
  }
  
  func toggleOneDay() {
    isOneDay.toggle()
    
    if isOneDay {
      endDate = startDate
    }
  }
  
  func updateYear(_ newYear: Int) {
    year = newYear
    let startOfYear = Calendar.current.date(from: DateComponents(year: newYear, month: 1, day: 1)) ?? Date()
    let endOfYear = Calendar.current.date(from: DateComponents(year: newYear, month: 12, day: 31)) ?? Date()
    
    if startDate < startOfYear || startDate > endOfYear {
      startDate = startOfYear
    }
    
    if endDate < startDate || endDate > endOfYear {
      endDate = isOneDay ? startDate : endOfYear
    }
  }
  
  func updateStartDate(_ newStartDate: Date) {
    startDate = newStartDate
    
    if isOneDay {
      endDate = newStartDate
    } else {
      if endDate < newStartDate {
        endDate = newStartDate
      }
    }
  }
  
  func onSave(by userId: UUID) -> RaceEdition {
    if let edition = edition {
      edition.year = year
      edition.startDate = startDate
      edition.endDate = endDate
      edition.photoData = photoData
      edition.cropPhotoData = cropPhotoData
      edition.updatedDate = .now
      
      return edition
    } else {
      let newEdition = RaceEdition(
        year: year,
        startDate: startDate,
        endDate: endDate,
        photoData: photoData,
        cropPhotoData: cropPhotoData,
        createBy: userId,
        race: race,
        categories: []
      )
      self.edition = newEdition
      
      return newEdition
    }
  }
}
