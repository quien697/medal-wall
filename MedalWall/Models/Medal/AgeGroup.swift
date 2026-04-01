//
//  AgeGroup.swift
//  MedalWall
//
//  Created by Quien on 2026-04-01.
//

/// Standard marathon age group brackets in 5-year increments.
enum AgeGroup: String, Codable, CaseIterable, Identifiable {
  case under20
  case from20to24
  case from25to29
  case from30to34
  case from35to39
  case from40to44
  case from45to49
  case from50to54
  case from55to59
  case from60to64
  case from65to69
  case from70to74
  case from75to79
  case over80
  
  var id: String { rawValue }
  
  var displayName: String {
    switch self {
    case .under20:    return "Under 20"
    case .from20to24: return "20-24"
    case .from25to29: return "25-29"
    case .from30to34: return "30-34"
    case .from35to39: return "35-39"
    case .from40to44: return "40-44"
    case .from45to49: return "45-49"
    case .from50to54: return "50-54"
    case .from55to59: return "55-59"
    case .from60to64: return "60-64"
    case .from65to69: return "65-69"
    case .from70to74: return "70-74"
    case .from75to79: return "75-79"
    case .over80:     return "80+"
    }
  }
  
  //  var lowerBound: Int? {
  //    switch self {
  //    case .under20:  return nil
  //    case .age20_24: return 20
  //    case .age25_29: return 25
  //    case .age30_34: return 30
  //    case .age35_39: return 35
  //    case .age40_44: return 40
  //    case .age45_49: return 45
  //    case .age50_54: return 50
  //    case .age55_59: return 55
  //    case .age60_64: return 60
  //    case .age65_69: return 65
  //    case .age70_74: return 70
  //    case .age75_79: return 75
  //    case .age80plus: return 80
  //    }
  //  }
  //
  //  var upperBound: Int? {
  //    switch self {
  //    case .under20:  return 19
  //    case .age20_24: return 24
  //    case .age25_29: return 29
  //    case .age30_34: return 34
  //    case .age35_39: return 39
  //    case .age40_44: return 44
  //    case .age45_49: return 49
  //    case .age50_54: return 54
  //    case .age55_59: return 59
  //    case .age60_64: return 64
  //    case .age65_69: return 69
  //    case .age70_74: return 74
  //    case .age75_79: return 79
  //    case .age80plus: return nil
  //    }
  //  }
  
  //  /// Returns the matching bracket for a given age, or `nil` if age is negative.
  //  static func bracket(for age: Int) -> AgeGroup? {
  //    guard age >= 0 else { return nil }
  //    if age < 20 { return .under20 }
  //    return allCases.first {
  //      guard let lower = $0.lowerBound else { return false }
  //      if let upper = $0.upperBound {
  //        return age >= lower && age <= upper
  //      } else {
  //        return age >= lower
  //      }
  //    }
  //  }
}
