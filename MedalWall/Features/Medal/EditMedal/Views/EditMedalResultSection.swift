//
//  EditMedalResultSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-14.
//

import SwiftUI

struct EditMedalResultSection: View {
  @Binding var finishTime: TimeInterval?
  
  var body: some View {
    Section("Result") {
      TimePicker("Finish Time", selection: $finishTime)
    }
  }
}

#Preview {
  Form {
    EditMedalResultSection(finishTime: .constant(nil))
    
    EditMedalResultSection(finishTime: .constant(5 * 3600 + 10 * 60 + 1))
  }
}
