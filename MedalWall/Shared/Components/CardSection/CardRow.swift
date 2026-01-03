//
//  CardRow.swift
//  MedalWall
//
//  Created by Quien on 2026-01-01.
//

import SwiftUI

struct CardRow<Content: View>: View {
  private let icon: String?
  private let label: String?
  private let value: String?
  private let withBottomLine: Bool
  private let content: Content
  
  init(
    icon: String,
    value: String,
    withBottomLine: Bool = true
  ) where Content == EmptyView {
    self.icon = icon
    self.label = nil
    self.value = value
    self.content = EmptyView()
    self.withBottomLine = withBottomLine
  }
  
  init(
    label: String,
    value: String,
    withBottomLine: Bool = true
  ) where Content == EmptyView {
    self.icon = nil
    self.label = label
    self.value = value
    self.content = EmptyView()
    self.withBottomLine = withBottomLine
  }
  
  init(
    icon: String,
    withBottomLine: Bool = true,
    @ViewBuilder content: () -> Content
  ) {
    self.icon = icon
    self.label = nil
    self.value = nil
    self.content = content()
    self.withBottomLine = withBottomLine
  }
  
  var body: some View {
    Group {
      HStack(alignment: .top) {
        if let icon {
          Image(systemName: icon)
          
          if let value {
            Text(value)
          } else {
            content
          }
          
          Spacer()
        }
        
        if let label {
          Text(label)
          
          Spacer()
          
          if let value {
            Text(value)
              .foregroundColor(.secondary)
          }
        }
      } // HStack
      
      if withBottomLine {
        Divider()
      }
    } // Group
  }
}

#Preview(traits: .sampleData) {
  
  CardSection(spacing: 10) {
    CardRow(icon: "person", value: "Tsung-Hsun, Liu")
    
    CardRow(icon: "globe") {
      Link(destination: URL(string: "https://google.com")!) {
        Text("Google")
      }
    }
    
    CardRow(icon: "paintpalette.fill") {
      VStack {
        Text("Red")
        Text("Blue")
      }
    }
    
    CardRow(label: "Full Name", value: "Tsung-Hsun, Liu", withBottomLine: false)
  }
  .padding()
}
