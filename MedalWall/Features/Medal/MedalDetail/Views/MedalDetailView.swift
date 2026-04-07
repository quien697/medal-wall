//
//  MedalDetailView.swift
//  MedalWall
//
//  Created by Quien on 2025-12-24.
//

import SwiftUI
import SwiftData

struct MedalDetailView: View {
  // MARK: - Environment
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  // MARK: - State
  @State private var isShowEditor = false
  @State private var isShowDeleteConfirm = false
  @State private var errorWrapper: ErrorWrapper?
  @State private var viewModel: MedalDetailViewModel
  
  // MARK: - Init
  init(medal: Medal) {
    self._viewModel = State(initialValue: MedalDetailViewModel(medal: medal))
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

     MedalDetailStatsSection(
      columns: viewModel.gridColumns,
      spacing: viewModel.gridSpacing,
      finishTime: viewModel.finishTimeText,
      averagePace: viewModel.averagePaceText,
      overallPlacement: viewModel.overallPlacementText,
      totalParticipants: viewModel.totalParticipantsText,
      division: viewModel.medal.division ?? "--",
      divisionPlacement: viewModel.divisionPlacementText,
      divisionTotal: viewModel.divisionTotalText,
      genderPlacement: viewModel.genderPlacementText,
      genderTotal: viewModel.genderTotalText
     )

      if let note = viewModel.medal.note, !note.isEmpty {
        MedalDetailNoteSection(note: note)
      }
      
      eventPhotosSection
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
}

#Preview {
  NavigationStack {
    MedalDetailView(medal: Medal.sampleData.first!)
  }
}
