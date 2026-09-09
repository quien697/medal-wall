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
  init(medal: Medal, personalRecordIDs: Set<String> = []) {
    self._viewModel = State(
      initialValue: MedalDetailViewModel(medal: medal, personalRecordIDs: personalRecordIDs)
    )
  }

  // MARK: - Body
  var body: some View {
    ScrollView {
      MedalDetailHeroSection(
        photoUrl: viewModel.medal.photoUrl,
        name: viewModel.medal.name
      )

      MedalDetailInfoSection(
        location: viewModel.medal.place.formatted,
        date: viewModel.medal.date.formattedMonthDayYear(),
        distance: viewModel.medal.distance.category.description,
        raceType: viewModel.medal.distance.type.displayName,
        bib: viewModel.medal.bibNumber
      )

      MedalDetailResultSection(
        finishTime: viewModel.finishTimeText,
        isPersonalRecord: viewModel.isPersonalRecord,
        averagePaceValue: viewModel.averagePaceValue,
        averagePaceUnit: viewModel.averagePaceUnit,
        overallPlacement: viewModel.overallPlacementText,
        overallTotal: viewModel.overallTotalText,
        genderPlacement: viewModel.genderPlacementText,
        genderTotal: viewModel.genderTotalText,
        divisionLabel: viewModel.divisionLabel,
        divisionPlacement: viewModel.divisionPlacementText,
        divisionTotal: viewModel.divisionTotalText
      )

      if viewModel.hasDay {
        MedalDetailDaySection(
          photos: viewModel.medal.eventPhotos,
          note: viewModel.noteText
        )
      }

      if !viewModel.medal.tags.isEmpty {
        MedalDetailTagsSection(tags: viewModel.medal.tags)
      }
    }
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

/// Builds a medal for the previews below — `#Preview` bodies are `ViewBuilder` closures,
/// which take declarations and view expressions but not assignments.
private func previewMedal(stripped: Bool = false) -> Medal {
  guard var medal = Medal.sampleData.first else {
    return Medal(
      name: "Sample",
      date: .now,
      bibNumber: "1",
      place: Place(countryCode: "TW", city: "Taipei"),
      distance: RaceDistance(category: .full, type: .inPerson),
      userID: "preview"
    )
  }

  if stripped {
    medal.finishTime = nil
    medal.overallPlacement = nil
    medal.totalParticipants = nil
    medal.division = nil
    medal.divisionPlacement = nil
    medal.divisionTotal = nil
    medal.genderPlacement = nil
    medal.genderTotal = nil
    medal.note = nil
    medal.eventPhotos = []
  }

  return medal
}

#Preview("Record holder") {
  NavigationStack {
    MedalDetailView(medal: previewMedal(), personalRecordIDs: [previewMedal().id])
  }  // NavigationStack
}

#Preview("Not a record") {
  NavigationStack {
    MedalDetailView(medal: previewMedal())
  }  // NavigationStack
}

#Preview("Nothing recorded") {
  NavigationStack {
    MedalDetailView(medal: previewMedal(stripped: true))
  }  // NavigationStack
}
