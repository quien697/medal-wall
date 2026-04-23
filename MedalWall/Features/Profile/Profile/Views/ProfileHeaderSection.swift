//
//  ProfileHeaderSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-04.
//

import SwiftUI

struct ProfileHeaderSection: View {
  let avatar: UIImage?
  let userName: String
  let bio: String?
  
  var body: some View {
    SectionContainer {
      HStack(alignment: .top) {
        AvatarImage(photo: avatar)
        
        VStack(alignment: .leading, spacing: 8) {
          Text("\(userName)")
            .font(.title)
            .fontWeight(.bold)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
          
          if let bio = bio, !bio.isEmpty {
            Text(bio)
              .font(.headline)
              .foregroundStyle(Color.Text.secondary)
          }
        }
        
        Spacer()
      }
    }
  }
}

#Preview {
  VStack {
    ProfileHeaderSection(avatar: UIImage(named: "quien"), userName: "Tsung-Hsun Liu", bio: "I am here to cross the finish line.")
    
    ProfileHeaderSection(avatar: nil, userName: "Tsung-Hsun Liu", bio: "Fike it till make it.")
  }
  .background(Color.backgroundPrimary)
}
