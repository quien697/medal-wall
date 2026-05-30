//
//  MedalDetailView.swift
//  MedalWall
//
//  Created by Quien on 2025-12-24.
//

import SwiftUI

struct MedalDetailView: View {
  // MARK: - Environment
  @Environment(\.dismiss) private var dismiss

  // MARK: - State
  @State private var viewModel: MedalDetailViewModel
  @State private var errorWrapper: ErrorWrapper?
  @State private var isPresentingEditMedal = false
  @State private var isPresentingDeleteMedalConfirm = false

  // MARK: - Init
  init(medal: Medal) {
    self._viewModel = State(initialValue: MedalDetailViewModel(medal: medal))
  }

  // MARK: - Body
  var body: some View {
    ScrollView {
      MedalDetailHeroSection(
        photoUrl: viewModel.medal.photoUrl,
        name: viewModel.medal.name,
        raceDistance: viewModel.medal.distance.category.description,
        raceDistanceType: viewModel.medal.distance.type.displayName,
        location: viewModel.medal.location.formatted,
        date: viewModel.medal.date.formattedMonthDayYear(),
        bib: viewModel.medal.bibNumber
      )

      MedalDetailStatsSection(
        finishTime: viewModel.finishTimeText,
        averagePace: viewModel.averagePaceText,
        overallPlacement: viewModel.overallPlacementText,
        totalParticipants: viewModel.totalParticipantsText,
        division: viewModel.divisionText,
        divisionPlacement: viewModel.divisionPlacementText,
        divisionTotal: viewModel.divisionTotalText,
        genderPlacement: viewModel.genderPlacementText,
        genderTotal: viewModel.genderTotalText
      )

      if let note = viewModel.medal.note, !note.isEmpty {
        MedalDetailNoteSection(note: note)
      }

      if !viewModel.medal.eventPhotos.isEmpty {
        MedalDetailEventPhotosSection(photos: viewModel.medal.eventPhotos)
      }

      if !viewModel.medal.tags.isEmpty {
        MedalDetailTagsSection(tags: viewModel.medal.tags)
      }
    }
    .navigationTitle(viewModel.medal.name)
    .navigationBarTitleDisplayMode(.inline)
    .background(Color.Background.primary)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Menu("More Options", systemImage: "ellipsis") {
          Button {
            isPresentingEditMedal = true
          } label: {
            Label("Edit Medal", systemImage: "square.and.pencil")
          }

          Divider()

          Button(role: .destructive) {
            isPresentingDeleteMedalConfirm = true
          } label: {
            Label("Delete Medal", systemImage: "trash")
          }
        }
      }
    }
    .alert(isPresented: $isPresentingDeleteMedalConfirm) {
      .deleteConfirmation(
        name: viewModel.medal.name,
        onDelete: {
          Task {
            do {
              try await viewModel.deleteMedal(viewModel.medal)
              dismiss()
            } catch {
              errorWrapper = ErrorWrapper(error: AppError.medalDeleteFailed)
            }
          }
        }
      )
    }
    .sheet(
      isPresented: $isPresentingEditMedal,
      onDismiss: {
        Task { await viewModel.reloadMedal() }
      },
      content: {
        EditMedalView(mode: .edit, medal: viewModel.medal)
      }
    )
    .sheet(
      item: $errorWrapper,
      onDismiss: nil,
      content: { wrapper in
        ErrorView(errorWrapper: wrapper)
      }
    )
  }
}

#Preview {
  NavigationStack {
    MedalDetailView(medal: Medal.sampleData.first!)
  }
}
