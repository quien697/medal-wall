//
//  MedalDetailView.swift
//  MedalWall
//
//  Created by Quien on 2025-12-24.
//

import SwiftUI
import SwiftData

struct MedalDetailView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var isShowEditor = false
  @State private var isShowDeleteConfirm = false
  @State private var errorWrapper: ErrorWrapper?
  @State private var viewModel: MedalDetailViewModel

  init(medal: Medal) {
    self._viewModel = State(initialValue: MedalDetailViewModel(medal: medal))
  }

  // MARK: - Computed

  private var resultColumns: [GridItem] {
    [
      GridItem(.flexible(minimum: 80), spacing: 12),
      GridItem(.flexible(minimum: 80), spacing: 12),
    ]
  }

  private var formattedPace: String {
    guard let pace = viewModel.medal.avgPace else { return "--'--\"" }
    let minutes = Int(pace)
    let seconds = Int((pace - Double(minutes)) * 60)
    return String(format: "%d'%02d\"/km", minutes, seconds)
  }

  private var overallPlacementText: String {
    guard let placement = viewModel.medal.overallPlacement,
          let total = viewModel.medal.totalParticipants else { return "--" }
    return "\(placement)/\(total)"
  }

  private var divisionPlacementText: String {
    guard let placement = viewModel.medal.divisionPlacement,
          let total = viewModel.medal.divisionTotal else { return "--" }
    return "\(placement)/\(total)"
  }

  private var genderPlacementText: String {
    guard let placement = viewModel.medal.genderPlacement,
          let total = viewModel.medal.genderTotal else { return "--" }
    return "\(placement)/\(total)"
  }

  private var hasResult: Bool {
    viewModel.medal.finishTime != nil || viewModel.medal.overallPlacement != nil
  }

  // MARK: - Body

  var body: some View {
    ScrollView {
      MedalDetailHeroSection(
        photo: viewModel.medal.cropPhoto ?? viewModel.medal.photo,
        name: viewModel.medal.name,
        raceDistance: viewModel.medal.raceDistanceCategory.description,
        raceDistanceType: viewModel.medal.raceDistanceType.displayName,
        location: viewModel.medal.location.formatted,
        date: viewModel.medal.date.formattedMonthDayYear(),
        bib: viewModel.medal.bibNumber
      )


      if hasResult {
        resultSection
      }

      eventPhotosSection

      if let note = viewModel.medal.note, !note.isEmpty {
        notesSection(note: note)
      }
    }
    .navigationTitle(viewModel.medal.name)
    .navigationBarTitleDisplayMode(.inline)
    .background(Color.Background.primary)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Menu("More Options", systemImage: "ellipsis") {
          Button {
            isShowEditor = true
          } label: {
            Label("Edit Medal", systemImage: "square.and.pencil")
          }

          Divider()

          Button(role: .destructive) {
            isShowDeleteConfirm = true
          } label: {
            Label("Delete Medal", systemImage: "trash")
          }
        }
      }
    }
//    .alert(isPresented: $isShowDeleteConfirm) {
//      .deleteConfirmation(name: viewModel.medal.title, onDelete: {
//        do {
//          try viewModel.configure(context: modelContext)
//          try viewModel.deleteMedal(viewModel.medal)
//          dismiss()
//        } catch {
//          errorWrapper = ErrorWrapper(error: AppError.unknown)
//        }
//      })
//    }
//    .sheet(isPresented: $isShowEditor) {
//      NavigationStack {
//        MedalEditView(medal: viewModel.medal)
//      }
//    }
//    .sheet(item: $errorWrapper, onDismiss: nil) { wrapper in
//      ErrorView(errorWrapper: wrapper)
//    }
  }

  // MARK: - Result

  private var resultSection: some View {
    SectionContainer(title: "Result") {
      LazyVGrid(columns: resultColumns, spacing: 12) {
        if let finishTime = viewModel.medal.finishTime {
          StatGridItem(
            title: finishTime.formattedHMS,
            subTitle: "Finish Time",
            titleColor: Color.Badge.Gold.primary
          )
        }

        if viewModel.medal.overallPlacement != nil {
          StatGridItem(title: overallPlacementText, subTitle: "Overall")
        }

        if viewModel.medal.avgPace != nil {
          StatGridItem(title: formattedPace, subTitle: "Avg Pace")
        }

        if viewModel.medal.divisionPlacement != nil {
          StatGridItem(
            title: divisionPlacementText,
            subTitle: viewModel.medal.division ?? "Division"
          )
        }

        if viewModel.medal.genderPlacement != nil {
          StatGridItem(title: genderPlacementText, subTitle: "Gender")
        }
      }
    }
  }

  // MARK: - Event Photos

  private var eventPhotosSection: some View {
    SectionContainer(title: "Event Photos") {
      ScrollView(.horizontal, showsIndicators: false) {
        HStack(spacing: 12) {
          if viewModel.medal.eventPhotos.isEmpty {
            ForEach(1...4, id: \.self) { index in
              placeholderEventPhoto(index: index)
            }
          } else {
            ForEach(
              viewModel.medal.eventPhotos.sorted(by: { $0.sortOrder < $1.sortOrder }),
              id: \.id
            ) { photo in
              if let image = photo.image {
                Image(uiImage: image)
                  .resizable()
                  .aspectRatio(contentMode: .fill)
                  .frame(width: 140, height: 110)
                  .clipShape(RoundedRectangle(cornerRadius: 12))
              }
            }
          }
        }
      }
    }
  }

  private func placeholderEventPhoto(index: Int) -> some View {
    RoundedRectangle(cornerRadius: 12)
      .fill(Color.Card.Background.secondary)
      .frame(width: 140, height: 110)
      .overlay(
        VStack(spacing: 6) {
          Image(systemName: "photo")
            .font(.system(size: 26))
            .foregroundStyle(Color.Text.tertiary)
          Text("Photo \(index)")
            .font(.caption)
            .foregroundStyle(Color.Text.tertiary)
        }
      )
      .overlay(
        RoundedRectangle(cornerRadius: 12)
          .stroke(Color.Border.gray, lineWidth: 1)
      )
  }

  // MARK: - Notes

  private func notesSection(note: String) -> some View {
    SectionContainer(title: "Notes") {
      Text(note)
        .font(.body)
        .foregroundStyle(Color.Text.primary)
        .frame(maxWidth: .infinity, alignment: .leading)
        .surfaceStyle()
    }
  }
}

#Preview {
  NavigationStack {
    MedalDetailView(medal: Medal.sampleData.first!)
  }
}
