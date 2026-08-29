//
//  Font+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2026-08-25.
//

import SwiftUI

extension Font {

  struct TypeScale {
    static let display = Font.system(size: 32, weight: .black)
    static let title1 = Font.system(size: 26, weight: .heavy)
    static let title2 = Font.system(size: 20, weight: .bold)
    static let headline = Font.system(size: 17, weight: .bold)
    static let body = Font.system(size: 17, weight: .regular)
    static let callout = Font.system(size: 15, weight: .medium)
    static let caption = Font.system(size: 13, weight: .medium)
    static let overline = Font.system(size: 11, weight: .bold)
    static let microLabel = Font.system(size: 10, weight: .bold)

    struct Field {
      static let label = Font.system(size: 15, weight: .bold)
      static let value = Font.system(size: 15, weight: .semibold).monospacedDigit()
    }

    struct Numeric {
      static let large = Font.system(size: 32, weight: .bold).monospacedDigit()
      static let medium = Font.system(size: 20, weight: .bold).monospacedDigit()
      static let small = Font.system(size: 15, weight: .semibold).monospacedDigit()
    }
  }
}
