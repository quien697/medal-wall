//
//  NoProfileView.swift
//  MedalWall
//
//  Created by Quien on 2026-04-20.
//

import SwiftUI

struct NoProfileView: View {
  var body: some View {
    ContentUnavailableView {
      Label("No User Found", systemImage: "person.fill")
    } description: {
      Text("Please restart the app")
    }
  }
}

#Preview {
  NoProfileView()
}
