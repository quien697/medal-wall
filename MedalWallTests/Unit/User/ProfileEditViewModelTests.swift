//
//  ProfileEditViewModelTests.swift
//  MedalWall
//
//  Created by Quien on 2025-12-08.
//

import Testing
import UIKit
@testable import MedalWall

struct ProfileEditViewModelTests {
  
  @Test("Init with nil")
  func testInitNil() throws {
    let vm = ProfileEditViewModel(profile: nil)
    
    #expect(vm.isNewProfile)
    #expect(vm.userName.firstName.isEmpty)
    #expect(vm.userName.lastName.isEmpty)
    #expect(vm.avatarData == nil)
    #expect(vm.bio.isEmpty)
    #expect(vm.gender == nil)
    #expect(vm.isBirthdaySet == false)
  }
  
  @Test("Init loads existing profile")
  func testInitExistingProfile() throws {
    let avatarImage = UIImage(named: "quien")
    let avatarData = avatarImage?.jpegData(compressionQuality: 0.9)
    let profile = User(
      name: .init(firstName: "Allen", lastName: "Wang"),
      avatarData: avatarData,
      gender: .male,
      birthday: .now
    )
    
    let vm = ProfileEditViewModel(profile: profile)
    
    #expect(vm.isNewProfile == false)
    #expect(vm.userName.firstName == "Allen")
    #expect(vm.userName.lastName == "Wang")
    #expect(vm.avatarData == avatarData)
    #expect(vm.gender == .male)
    #expect(vm.isBirthdaySet)
  }
  
  @Test("Form validation works")
  func testFormValidation() throws {
    let vm = ProfileEditViewModel(profile: nil)
    vm.userName.firstName = "Quien"
    #expect(vm.isFormValid == false)
    
    vm.userName.lastName = "Liu"
    #expect(vm.isFormValid == true)
  }
  
  @Test("Update avatar with valid image")
  func testUpdateAvatarValid() throws {
    let vm = ProfileEditViewModel(profile: nil)
    let data = UIImage(named: "quien")?.jpegData(compressionQuality: 0.9)
    
    #expect(vm.avatarData == nil)
    #expect(vm.avatar == nil)
    
    vm.updatePhoto(with: data)
    
    #expect(vm.avatarData == data)
    #expect(vm.avatar != nil)
  }
  
  @Test("update avatar with invalid image")
  func testUpdateAvatarInvalid() throws {
    let vm = ProfileEditViewModel(profile: nil)
    let invalid = "not an image".data(using: .utf8)!
    
    #expect(vm.avatarData == nil)
    #expect(vm.avatar == nil)
    
    vm.updatePhoto(with: invalid)
    
    #expect(vm.avatarData == invalid)
    #expect(vm.avatar == nil)
  }
  
  @Test("clear avatar")
  func testClearAvatar() throws {
    let vm = ProfileEditViewModel(profile: nil)
    let data = UIImage(named: "quien")?.jpegData(compressionQuality: 0.9)
    vm.updatePhoto(with: data)
    
    #expect(vm.avatarData == data)
    #expect(vm.avatar != nil)
    
    vm.clearPhoto()
    
    #expect(vm.avatarData == nil)
    #expect(vm.avatar == nil)
  }
}
