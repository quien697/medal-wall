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
    PageSection {
      HStack(alignment: .top) {
        PhotoImage(urlString: photoUrl, as: .avatar)

        VStack(alignment: .leading, spacing: 8) {
          Text(userName)
            .font(.TypeScale.title2)
            .foregroundStyle(Color.Text.primary)
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .skeletonBone(.title2)

          if let bio, !bio.isEmpty {
            Text(bio)
              .font(.TypeScale.body)
              .foregroundStyle(Color.Text.secondary)
              .skeletonBone(.body)
          }
        }  // VStack

        Spacer()
      }  // HStack
    }  // PageSection
  }
}

#Preview {
  VStack {
    ProfileHeaderSection(
      photoUrl: nil, userName: "Tsung-Hsun Liu", bio: "I am here to cross the finish line.")
  }
  .background(Color.Background.primary)
}

#Preview("Loading") {
  ProfileHeaderSection(
    photoUrl: nil, userName: User.placeholder.name, bio: User.placeholder.bio
  )
  .skeleton(true)
  .background(Color.Background.primary)
}
