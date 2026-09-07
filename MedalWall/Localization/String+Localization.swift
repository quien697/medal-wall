//
//  String+Localization.swift
//  MedalWall
//
//  Created by Quien on 2026-08-11.
//

import Foundation

extension String {

  /// Looks a String Catalog key up using the app's stored language preference.
  ///
  /// For display strings built outside a SwiftUI `body` — model and ViewModel computed
  /// properties — which cannot read `\.locale` from the environment. Inside a view,
  /// prefer `Text("key")` and let the injected environment locale resolve it.
  nonisolated static func appLocalized(
    _ key: String.LocalizationValue,
    defaults: UserDefaults = .standard
  ) -> String {
    String(
      localized: key,
      bundle: AppLanguage.resolvedBundle(from: defaults),
      locale: AppLanguage.resolvedLocale(from: defaults)
    )
  }
}
