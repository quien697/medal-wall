//
//  AgeGroup.swift
//  MedalWall
//
//  Created by Quien on 2026-04-01.
//

/// Standard marathon age group brackets.
/// Supports both 5-year increments and 10-year increments
enum AgeGroup: String, Codable, CaseIterable, Identifiable {
  // MARK: - 5-Year Brackets
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

  // MARK: - 10-Year Brackets
  case from20to29
  case from30to39
  case from40to49
  case from50to59
  case from60to69
  case from70to79

  var id: String { rawValue }

  var displayName: String {
    switch self {
    case .under20:    return "Under 20"
    case .from20to24: return "20–24"
    case .from25to29: return "25–29"
    case .from30to34: return "30–34"
    case .from35to39: return "35–39"
    case .from40to44: return "40–44"
    case .from45to49: return "45–49"
    case .from50to54: return "50–54"
    case .from55to59: return "55–59"
    case .from60to64: return "60–64"
    case .from65to69: return "65–69"
    case .from70to74: return "70–74"
    case .from75to79: return "75–79"
    case .over80:     return "80+"
    case .from20to29: return "20–29"
    case .from30to39: return "30–39"
    case .from40to49: return "40–49"
    case .from50to59: return "50–59"
    case .from60to69: return "60–69"
    case .from70to79: return "70-79"
    }
  }

  static var fiveYearCases: [AgeGroup] = [
    .under20, .from20to24, .from25to29, .from30to34, .from35to39,
    .from40to44, .from45to49, .from50to54, .from55to59, .from60to64,
    .from65to69, .from70to74, .from75to79, .over80
  ]

  static var tenYearCases: [AgeGroup] = [
    .from20to29, .from30to39, .from40to49, .from50to59, .from60to69, .from70to79
  ]
}
