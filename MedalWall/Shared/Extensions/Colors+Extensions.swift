//
//  Colors+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2026-03-04.
//

import SwiftUI

extension Color {
  struct Background {
    static let primary = Color("BackgroundPrimary")
  }

  struct Border {
    static let gray = Color("BorderGray")
  }

  struct Card {
    struct Background {
      static let primary = Color("CardBackgroundPrimary")
      static let secondary = Color("CardBackgroundSecondary")
      static let tertiary = Color("CardBackgroundTertiary")
    }
  }

  struct Text {
    static let primary = Color("TextPrimary")
    static let secondary = Color("TextSecondary")
    static let tertiary = Color("TextTertiary")
  }

  struct Gold {
    static let primary = Color.accentColor
    static let secondary = Color("GoldSecondary")
  }
}
