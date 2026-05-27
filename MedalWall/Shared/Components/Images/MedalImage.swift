//
//  MedalImage.swift
//  MedalWall
//
//  Created by Quien on 2025-12-30.
//

import SwiftUI

struct MedalImage: View {
  private let systemImageName: String = "medal.fill"
  private let imageType: ImageType = .medal
  private let photo: UIImage?
  private let urlString: String?
  private let size: CGFloat

  /// Displays a locally held UIImage (e.g. a newly selected photo not yet uploaded).
  init(photo: UIImage? = nil) {
    self.photo = photo
    self.urlString = nil
    self.size = imageType.size.width
  }

  /// Fetches and displays an image from a URL string, falling back to the placeholder if nil or
  /// loading fails.
  init(urlString: String?) {
    self.photo = nil
    self.urlString = urlString
    self.size = imageType.size.width
  }

  var body: some View {
    ZStack {
      Hexagon()
        .strokeBorder(
          LinearGradient(
            stops: [
              .init(color: Color.Gold.secondary, location: 0.0),
              .init(color: Color.Gold.primary, location: 0.35),
              .init(color: Color.Gold.secondary, location: 0.5),
              .init(color: Color.Gold.primary, location: 0.75),
              .init(color: Color.Gold.secondary.opacity(0.8), location: 1.0)
            ],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
          ),
          style: StrokeStyle(
            lineWidth: max(1, size * 0.06),
            lineJoin: .round
          )
        )
        .overlay(
          Hexagon()
            .strokeBorder(
              Color.Gold.secondary.opacity(0.2),
              lineWidth: 1
            )
        )
        .shadow(
          color: Color.Gold.primary.opacity(0.25),
          radius: 3,
          x: 0,
          y: 2
        )
        .frame(width: size * 0.9, height: size)

      if let uiImage = photo {
        Image(uiImage: uiImage)
          .resizable()
          .scaledToFill()
          .frame(width: size * 0.72, height: size * 0.72)
          .clipShape(imageType.shape)
          .shadow(radius: 6, x: 6, y: 6)
      } else if let urlString, let url = URL(string: urlString) {
        AsyncImage(url: url) { phase in
          switch phase {
          case .success(let image):
            image
              .resizable()
              .scaledToFill()
              .frame(width: size * 0.72, height: size * 0.72)
              .clipShape(imageType.shape)
              .shadow(radius: 6, x: 6, y: 6)
          default:
            placeholder
          }
        }
      } else {
        placeholder
      }
    }  // ZStack
  }

  private var placeholder: some View {
    Image(systemName: systemImageName)
      .font(.system(size: size * 0.3, weight: .semibold))
      .foregroundColor(Color.Gold.primary)
  }
}

#Preview {
  VStack(spacing: 20) {
    MedalImage(photo: nil)
      .background(Color.Background.primary)

    MedalImage(
      photo: UIImage(named: "bmo-vancouver-marathon")
    )
    .background(Color.Background.primary)
  }
}
