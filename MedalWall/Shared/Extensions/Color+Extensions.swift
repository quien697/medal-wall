//
//  Color+Extensions.swift
//  MedalWall
//
//  Created by Quien on 2026-03-04.
//

import SwiftUI

extension Color {
  /// Every control — bar actions, buttons, links, focus. Gold is never tappable,
  /// so `Record` only ever describes something the user earned.
  static let interactive = Color.accentColor

  struct Background {
    static let primary = Color("BackgroundPrimary")
  }

  struct Border {
    static let primary = Color("BorderPrimary")
    static let gray = Color("BorderPrimary")  // delete later
  }

  struct Card {  // delete later
    struct Background {
      static let primary = Color("SurfacePrimary")
      static let secondary = Color("SurfaceSecondary")
      static let tertiary = Color("SurfaceTertiary")
    }
  }

  struct Surface {
    static let primary = Color("SurfacePrimary")
    static let secondary = Color("SurfaceSecondary")
    static let tertiary = Color("SurfaceTertiary")
  }

  struct Text {
    static let primary = Color("TextPrimary")
    static let secondary = Color("TextSecondary")
    static let tertiary = Color("TextTertiary")
    static let placeholder = Color("TextPlaceholder")
  }

  struct Gold {  // delete later
    static let primary = Color("RecordPrimary")
    static let secondary = Color("RecordChampagne")
  }

  struct Record {
    static let primary = Color("RecordPrimary")
    static let champagne = Color("RecordChampagne")
    static let ink = Color("RecordInk")
  }

  struct Status {
    static let success = Color("StatusSuccess")
    static let successSurface = Color("StatusSuccessSurface")
    static let error = Color("StatusError")
    static let errorSurface = Color("StatusErrorSurface")
  }
}
