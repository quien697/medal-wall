//
//  SkeletonViewModifier.swift
//  MedalWall
//
//  Created by Quien on 2026-10-19.
//

import SwiftUI

/// What a bone sits on, which picks its colour.
enum SkeletonSurface {
  case page
  case card

  /// Internal so a test can read the colour a surface resolves to.
  var boneColor: Color {
    switch self {
    case .page: Color.Skeleton.onPage
    case .card: Color.Skeleton.inCard
    }
  }
}

extension EnvironmentValues {
  /// What the bones below sit on. `surfaceStyle()` sets `.card` for its content.
  @Entry var skeletonSurface: SkeletonSurface = .page
}

/// The height of a bar bone, named by the type step of the text it stands in for, or by the
/// tag or chip it covers.
///
/// The heights are the iOS mockup's bars, which follow the font rather than the line, so every
/// bar of one text style matches across the app; a tag and a chip share a height, so a row of
/// them lines up. The design system names no bone sizes, so `deviations.md` records these.
enum BoneSize {
  case title2
  case headline
  case body
  case callout
  case caption
  case overline
  case numericMedium
  case numericLarge
  case tag
  case chip

  var height: CGFloat {
    switch self {
    case .overline, .caption: 10
    case .body: 12
    case .callout: 14
    case .headline: 16
    case .numericMedium: 18
    case .tag, .chip: 20
    case .title2: 24
    case .numericLarge: 30
    }
  }

  /// A chip's bar is a capsule, as the chip is; every other bar takes `Radius.tag`.
  var cornerRadius: CGFloat {
    self == .chip ? height / 2 : .Radius.tag
  }
}

/// A bar standing in for a line of text, a tag or a chip: as wide as the content, at its own
/// height, centred in the content's frame and never taller than it.
nonisolated struct BarBone: Shape {
  let height: CGFloat
  let cornerRadius: CGFloat

  /// The bar inside the content's frame.
  func path(in rect: CGRect) -> Path {
    let barHeight = min(height, rect.height)
    return RoundedRectangle(cornerRadius: cornerRadius)
      .path(in: rect.insetBy(dx: 0, dy: (rect.height - barHeight) / 2))
  }
}

/// A view modifier that shows a view's placeholder content as a skeleton while its section
/// loads, and changes nothing otherwise.
///
/// Redaction reaches every descendant, so each `.skeletonBone(_:)` below turns into its bone.
/// Nothing shows for the first 300 ms, so a quick load never flashes bones; then the bones
/// pulse, or hold still at full opacity when Reduce Motion is on. That delay and pulse apply
/// to everything wrapped, so wrap only data: a section title belongs outside, real from the
/// first frame. A `TimelineView` drives the pulse, so it stops the moment the skeleton turns
/// off, where a repeating animation would keep running. VoiceOver reads the whole skeleton as
/// one "Loading" element, so it never reads out placeholder data.
struct SkeletonViewModifier: ViewModifier {
  // MARK: - Environment
  @Environment(\.accessibilityReduceMotion) private var isReduceMotionOn

  // MARK: - State
  /// When the bones appeared, 300 ms after the skeleton turned on; `nil` until then.
  @State private var revealDate: Date?

  // MARK: - Properties
  let isActive: Bool

  // MARK: - Computed
  /// The pulse runs only while revealed bones show and Reduce Motion is off.
  private var isPulsing: Bool {
    isActive && revealDate != nil && !isReduceMotionOn
  }

  // MARK: - Body
  func body(content: Content) -> some View {
    TimelineView(.animation(paused: !isPulsing)) { timeline in
      content
        .opacity(
          Self.opacity(
            isActive: isActive,
            secondsSinceReveal: revealDate.map { timeline.date.timeIntervalSince($0) },
            isReduceMotionOn: isReduceMotionOn
          )
        )
    }  // TimelineView
    .redacted(reason: isActive ? .placeholder : [])
    .allowsHitTesting(!isActive)
    .scrollDisabled(isActive)
    .accessibilityHidden(isActive)
    .overlay {
      if isActive {
        Color.clear
          .accessibilityElement()
          .accessibilityLabel("Loading")
      }
    }
    .task(id: isActive) {
      revealDate = nil
      guard isActive else { return }

      try? await Task.sleep(for: .milliseconds(300))
      guard !Task.isCancelled else { return }

      revealDate = .now
    }
  }

  // MARK: - Functions
  /// The skeleton's opacity: full while inactive; hidden until its bones are revealed; then a
  /// pulse from 0.6 up to 1 over 1.2 s and back, easing in and out, or full and still under
  /// Reduce Motion. Internal so a test can read it.
  static func opacity(
    isActive: Bool,
    secondsSinceReveal: TimeInterval?,
    isReduceMotionOn: Bool
  ) -> Double {
    guard isActive else { return 1 }
    guard let secondsSinceReveal else { return 0 }
    guard !isReduceMotionOn else { return 1 }

    // A frame can be timed a moment before the reveal; it reads as the start of the pulse.
    let phase = max(0, secondsSinceReveal).truncatingRemainder(dividingBy: 2.4) / 2.4
    return 0.6 + 0.4 * (1 - cos(2 * .pi * phase)) / 2
  }
}

/// A view modifier that stands a bone in for one piece of data while a skeleton shows.
///
/// Inside `.skeleton(_:)` the content keeps its frame but is hidden, and the bone sits in that
/// frame in the colour for what it sits on — covering text, gold and navy alike, which
/// redaction alone would only fade. Anywhere else the content shows unchanged.
struct SkeletonBoneViewModifier<BoneShape: Shape>: ViewModifier {
  // MARK: - Environment
  @Environment(\.redactionReasons) private var redactionReasons
  @Environment(\.skeletonSurface) private var skeletonSurface

  // MARK: - Properties
  let shape: BoneShape

  // MARK: - Body
  func body(content: Content) -> some View {
    if redactionReasons.contains(.placeholder) {
      content
        .hidden()
        .overlay(shape.fill(skeletonSurface.boneColor))
    } else {
      content
    }
  }
}

extension View {

  /// Shows this view's placeholder content as a skeleton while `isActive`, and changes nothing
  /// otherwise, so a screen builds the view once and passes whether its data is still loading.
  func skeleton(_ isActive: Bool) -> some View {
    modifier(SkeletonViewModifier(isActive: isActive))
  }

  /// Stands a bone in `shape` in for this piece of data while a skeleton shows, covering it
  /// whole: for a photo, a ring, a seal or a progress bar.
  func skeletonBone<BoneShape: Shape>(_ shape: BoneShape) -> some View {
    modifier(SkeletonBoneViewModifier(shape: shape))
  }

  /// Stands a bar of `size` in for this line of text, tag or chip while a skeleton shows.
  func skeletonBone(_ size: BoneSize) -> some View {
    skeletonBone(BarBone(height: size.height, cornerRadius: size.cornerRadius))
  }
}

#Preview("On the page and in a card") {
  VStack(alignment: .leading, spacing: .Space.section) {
    HStack(spacing: .Space.row) {
      Circle()
        .fill(Color.Record.earned)
        .frame(width: 72, height: 72)
        .skeletonBone(.circle)

      VStack(alignment: .leading, spacing: .Space.inline) {
        Text("Alex Chen")
          .font(.TypeScale.title2)
          .skeletonBone(.title2)

        Text("Runner, Taipei")
          .font(.TypeScale.caption)
          .skeletonBone(.caption)
      }  // VStack
    }  // HStack
    .skeleton(true)

    Text("Achievements")
      .sectionTitleStyle()

    VStack(alignment: .leading, spacing: .Space.inline) {
      Text("Full Marathon")
        .font(.TypeScale.headline)
        .skeletonBone(.headline)

      ProgressBar(value: 0.4)
    }  // VStack
    .frame(maxWidth: .infinity, alignment: .leading)
    .surfaceStyle()
    .skeleton(true)
  }  // VStack
  .padding()
  .frame(maxHeight: .infinity, alignment: .top)
  .background(Color.Background.primary)
}
