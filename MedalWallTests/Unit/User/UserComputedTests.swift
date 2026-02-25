//
//  UserComputedTests.swift
//  MedalWallTests
//

import Testing
@testable import MedalWall
import UIKit

struct UserComputedTests {
  
  @Test("avatar returns UIImage when photoData present and nil otherwise")
  func testAvatarConversion() {
    let photo = UIImage(systemName: "person.fill")!
    let photoData = photo.pngData()!
    
    let user1 = User(name: UserName(firstName: "A", lastName: "B"), avatarData: photoData)
    #expect(user1.avatar != nil)
    
    let user2 = User(name: UserName(firstName: "A", lastName: "B"))
    #expect(user2.avatar == nil)
  }
  
  @Test("croped avatar returns UIImage when cropPhotoData present and nil otherwise")
  func testCropedAvatarConversion() {
    let cropPhoto = UIImage(systemName: "person.fill")!
    let cropPhotoData = cropPhoto.pngData()!
    
    let user1 = User(name: UserName(firstName: "A", lastName: "B"), cropAvatarData: cropPhotoData)
    #expect(user1.cropAvatar != nil)
    
    let user2 = User(name: UserName(firstName: "A", lastName: "B"))
    #expect(user2.cropAvatar == nil)
  }
  
  @Test("genderEnum returns nil when gender is nil")
  func testGenderWithNil() {
    let user = User(gender: nil)
    
    #expect(user.genderEnum == nil)
  }
  
  @Test("genderEnum returns correct enum when gender is valid")
  func testGenderIsValid() {
    let user = User()
    
    user.gender = "male"
    #expect(user.genderEnum == Gender.male)
    #expect(user.genderEnum?.displayName == "Male")
    
    user.gender = "female"
    #expect(user.genderEnum == Gender.female)
    #expect(user.genderEnum?.displayName == "Female")
  }
  
  @Test("genderEnum returns nil when gender raw value is invalid")
  func testGenderIsInvalid() {
    let user = User()
    user.gender = "xxx"
    
    #expect(user.genderEnum == nil)
  }
  
  @Test("fullName returns combined and trimmed name")
  func testFormattedFullName() {
    let user = User(name: UserName(firstName: "  Alice ", lastName: " Smith  "))
    
    #expect(user.fullName == "Alice, Smith")
  }
}
