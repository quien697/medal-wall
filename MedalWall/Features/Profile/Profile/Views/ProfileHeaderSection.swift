//
//  ProfileHeaderSection.swift
//  MedalWall
//
//  Created by Quien on 2026-03-04.
//

import SwiftUI

struct ProfileHeaderSection: View {
  let photoUrl: String?
  let userName: String
  let bio: String?

  var body: some View {
    SectionContainer {
      HStack(alignment: .top) {
        AvatarImage(photoUrl: photoUrl)

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
    ProfileHeaderSection(
      photoUrl: nil, userName: "Tsung-Hsun Liu", bio: "I am here to cross the finish line.")
    ProfileHeaderSection(
      photoUrl: nil, userName: "Tsung-Hsun Liu", bio: "Fake it till you make it.")
  }
  .background(Color.Background.primary)
}
