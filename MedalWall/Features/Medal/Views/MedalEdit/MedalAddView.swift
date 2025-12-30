//
//  MedalAddView.swift
//  MedalWall
//
//  Created by Quien on 2025-12-21.
//

import SwiftUI

struct MedalAddView: View {
  let user: User
  
  var body: some View {
    MedalEditView(medal: nil, user: user)
  }
}

#Preview {
  MedalAddView(user: User.defaultUser)
}
