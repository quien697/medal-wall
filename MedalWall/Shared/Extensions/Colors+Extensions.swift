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
    static let gray = Color(.black).opacity(0.1)
  }
  
  struct Card {
    struct Background {
      static let primary   = Color("CardBackgroundPrimary")
      static let secondary = Color("CardBackgroundSecondary")
      static let tertiary  = Color("CardBackgroundTertiary")
    }
  }
  
  struct Text {
    static let primary   = Color("TextPrimary")
    static let secondary = Color("TextSecondary")
    static let tertiary  = Color("TextTertiary")
  }
  
  struct Badge {
    struct Gold {
      static let primary   = Color("BadgeGoldPrimary")
      static let secondary = Color("BadgeGoldSecondary")
    }
    struct Silver {
      static let primary   = Color("BadgeSilverPrimary")
      static let secondary = Color("BadgeSilverSecondary")
    }
    struct Bronze {
      static let primary   = Color("BadgeBronzePrimary")
      static let secondary = Color("BadgeBronzeSecondary")
    }
  }
}
