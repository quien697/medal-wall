//
//  MedalDetailEventPhotosSection.swift
//  MedalWall
//
//  Created by Quien on 2026-04-07.
//

import SwiftUI

struct MedalDetailEventPhotosSection: View {
  let photots: [EventPhoto]
  
  var body: some View {
    SectionContainer(title: "Event Photos") {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          if photots.isEmpty {
            ForEach(1...4, id: \.self) { index in
              Image(systemName: "photo.fill")
                .placeholderStyled(as: ImageType.raceHero)
            }
          } else {
            //            ForEach(
            //              viewModel.medal.eventPhotos.sorted(by: { $0.sortOrder < $1.sortOrder }),
            //              id: \.id
            //            ) { photo in
            //              if let image = photo.image {
            //                Image(uiImage: image)
            //                  .resizable()
            //                  .aspectRatio(contentMode: .fill)
            //                  .frame(width: 140, height: 110)
            //                  .clipShape(RoundedRectangle(cornerRadius: 12))
            //              }
            //            }
          }
        }
      }
    }
    
  }
}

#Preview {
  ScrollView {
    MedalDetailEventPhotosSection(photots: [])
  }
}
