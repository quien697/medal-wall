//
//  ButtonViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-03-23.
//

import SwiftUI

struct ButtonViewModifier: ViewModifier {
  let font: Font
  let fontWeight: Font.Weight
  let fgColor: Color
  let bgColor: Color
  let vPadding: CGFloat
  let hPadding: CGFloat
  
  func body(content: Content) -> some View {
    content
      .font(font)
      .fontWeight(fontWeight)
      .foregroundStyle(fgColor)
      .padding(.vertical, vPadding)
      .padding(.horizontal, hPadding)
      .background(bgColor)
      .clipShape(.capsule)
      .overlay(
        Capsule()
          .stroke(Color.Border.gray, lineWidth: 1)
      )
  }
}

extension View {
  
  func primaryButtonStyle(
    font: Font = .subheadline,
    fontWeight: Font.Weight = .semibold,
    fgColor: Color = Color.Text.primary,
    bgColor: Color = Color.Card.Background.primary,
    vPadding: CGFloat = 8,
    hPadding: CGFloat = 12
  ) -> some View {
    modifier(ButtonViewModifier(
      font: font,
      fontWeight: fontWeight,
      fgColor: fgColor,
      bgColor: bgColor,
      vPadding: vPadding,
      hPadding: hPadding
    ))
  }
  
  func secondaryButtonStyle(
    font: Font = .subheadline,
    fontWeight: Font.Weight = .semibold,
    fgColor: Color = Color.Text.secondary,
    bgColor: Color = Color.Card.Background.secondary,
    vPadding: CGFloat = 8,
    hPadding: CGFloat = 12
  ) -> some View {
    modifier(ButtonViewModifier(
      font: font,
      fontWeight: fontWeight,
      fgColor: fgColor,
      bgColor: bgColor,
      vPadding: vPadding,
      hPadding: hPadding
    ))
  }
  
  func tertiaryButtonStyle(
    font: Font = .subheadline,
    fontWeight: Font.Weight = .semibold,
    fgColor: Color = Color.Text.tertiary,
    bgColor: Color = Color.Card.Background.tertiary,
    vPadding: CGFloat = 8,
    hPadding: CGFloat = 12
  ) -> some View {
    modifier(ButtonViewModifier(
      font: font,
      fontWeight: fontWeight,
      fgColor: fgColor,
      bgColor: bgColor,
      vPadding: vPadding,
      hPadding: hPadding
    ))
  }
  
  func goldFillButtonStyle(
    font: Font = .subheadline,
    fontWeight: Font.Weight = .semibold,
    fgColor: Color = Color.Text.primary,
    bgColor: Color = Color.Badge.Gold.primary,
    vPadding: CGFloat = 8,
    hPadding: CGFloat = 12
  ) -> some View {
    modifier(ButtonViewModifier(
      font: font,
      fontWeight: fontWeight,
      fgColor: fgColor,
      bgColor: bgColor,
      vPadding: vPadding,
      hPadding: hPadding
    ))
  }
  
  func goldOutLineButtonStyle(
    font: Font = .subheadline,
    fontWeight: Font.Weight = .semibold,
    fgColor: Color = Color.Badge.Gold.secondary,
    bgColor: Color = Color.Card.Background.secondary,
    vPadding: CGFloat = 8,
    hPadding: CGFloat = 12
  ) -> some View {
    modifier(ButtonViewModifier(
      font: font,
      fontWeight: fontWeight,
      fgColor: fgColor,
      bgColor: bgColor,
      vPadding: vPadding,
      hPadding: hPadding
    ))
  }
}

#Preview {
  Text("Test Data")
    .primaryButtonStyle()
  
  Text("Test Data")
    .secondaryButtonStyle()
  
  Text("Test Data")
    .tertiaryButtonStyle()
  
  Text("Test Data")
    .goldFillButtonStyle()
  
  Text("Test Data")
    .goldOutLineButtonStyle()
}
