//
//  RaceEditViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2025-11-18.
//

import Testing
import Foundation
import UIKit
import SwiftData
@testable import MedalWall

struct RaceEditViewModelTests {
  
  @Test("Init with nil")
  func testInitNil() throws {
    let vm = RaceEditViewModel(race: nil)
    
    #expect(vm.isNewRace)
    #expect(vm.name.isEmpty)
    #expect(vm.photoData == nil)
    #expect(vm.country.isEmpty)
    #expect(vm.distances.isEmpty)
  }
  
  @Test("Init loads existing race")
  func testInitExistingRace() throws {
    let race = Race(
      name: "Taipei Marathon",
      photoData: UIImage(named: "taipei-marathon")?.jpegData(compressionQuality: 0.9),
      date: DateComponents(calendar: .current, year: 2025, month: 12, day: 21).date!,
      location: RaceLocation(country: "Taiwan", city: "Taipei"),
      url: "https://taipeicitymarathon.com",
      updateTime: .now
    )
    race.categories = [
      RaceCategory(
        distance: RaceDistance(category: .full, type: .inPerson),
        race: race
      ),
      RaceCategory(
        distance: RaceDistance(category: .half, type: .inPerson),
        race: race
      ),
      RaceCategory(
        distance: RaceDistance(category: .half, type: .virtual),
        race: race
      )
    ]
    let vm = RaceEditViewModel(race: race)
    
    #expect(vm.isNewRace == false)
    #expect(vm.name == "Taipei Marathon")
    #expect(vm.city == "Taipei")
    #expect(vm.url == "https://taipeicitymarathon.com")
  }
  
  @Test("Form validation works")
  func testFormValidation() throws {
    let vm = RaceEditViewModel(race: nil)
    vm.name = ""
    vm.country = "Taiwan"
    vm.city = "Taipei"
    #expect(vm.isFormValid == false)
    
    vm.name = "Race"
    #expect(vm.isFormValid == true)
  }
  
  @Test("Update photo with valid image")
  func testUpdatePhotoValid() throws {
    let vm = RaceEditViewModel(race: nil)
    let data = UIImage(named: "bmo-vancouver-marathon")?.pngData()
    
    #expect(vm.photoData == nil)
    #expect(vm.photo == nil)
    
    vm.updatePhoto(with: data)
    
    #expect(vm.photoData == data)
    #expect(vm.photo != nil)
  }
  
  @Test("update photo with invalid image")
  func testUpdatePhotoInvalid() throws {
    let vm = RaceEditViewModel(race: nil)
    let invalid = "not an image".data(using: .utf8)!
    
    #expect(vm.photoData == nil)
    #expect(vm.photo == nil)
    
    vm.updatePhoto(with: invalid)
    
    #expect(vm.photoData == invalid)
    #expect(vm.photo == nil)
  }
  
  @Test("clear photo")
  func testClearPhoto() throws {
    let vm = RaceEditViewModel(race: nil)
    let data = UIImage(named: "bmo-vancouver-marathon")?.pngData()
    vm.updatePhoto(with: data)
    
    #expect(vm.photoData == data)
    #expect(vm.photo != nil)
    
    vm.clearPhoto()
    
    #expect(vm.photoData == nil)
    #expect(vm.photo == nil)
  }
  
  @Test("Add distances with the correct value")
  func testAddDistance() throws {
    let vm = RaceDistanceFactory()
    #expect(vm.distances.count == 5)
    
    try vm.addDistance(RaceDistance(category: .custom(33), type: .virtual))
    
    #expect(vm.distances.count == 6)
  }
  
  @Test("Add distances should throw duplicate error")
  func testAddDistanceDuplicateError() throws {
    let vm = RaceDistanceFactory()
    
    #expect(throws: AppError.duplicateDistance) {
      try vm.addDistance(RaceDistance.default)
    }
  }
  
  @Test("Updating a distance replaces the correct value")
  func testUpdateDistance() throws {
    let vm = RaceDistanceFactory()
    let old = vm.distances[1]
    let new = RaceDistance(category: .custom(25), type: .inPerson)
    
    try vm.updateDistance(old: old, with: new)
    
    #expect(vm.distances.count == 5)
    #expect(vm.distances.contains(new))
  }
  
  @Test("Updating to an existing distance should throw duplicate error")
  func testUpdateDistanceDuplicateError() throws {
    let vm = RaceDistanceFactory()
    let old = vm.distances[1]
    let new = vm.distances[0]
    
    #expect(throws: AppError.duplicateDistance) {
      try vm.updateDistance(old: old, with: new)
    }
  }
  
  @Test("Delete distances")
  func testDeleteDistance() throws {
    let vm = RaceDistanceFactory()
    let distance = RaceDistance(category: .`5K`, type: .inPerson)
    
    vm.deleteDistance(distance)
    
    #expect(vm.distances.count == 4)
    #expect(!vm.distances.contains(distance))
  }
}
