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
  
  private let size: CGFloat = 160
  
  init(medal: Medal) {
    self._viewModel = State(initialValue: MedalDetailViewModel(medal: medal))
  }
  
  var body: some View {
    let category = RaceDistanceCategory(value: viewModel.medal.raceCategory.distance)
    
    ScrollView {
      CardSection {
        MedalBadgeView(
          photo: viewModel.medal.photo,
          color: category.color
        )
        .frame(maxWidth: .infinity)
        
        Text(viewModel.medal.title)
          .font(.title2)
          .bold()
        
        Text(viewModel.medal.raceCategory.race.location.formatted)
          .font(.subheadline)
          .foregroundStyle(.secondary)
      } // CardSection
      
      CardSection(title: "Details") {
        CardListItem {
          Text("Date")
            .font(.callout)
            .fontWeight(.semibold)
          
          Spacer()
          
          Text(viewModel.medal.date, format: .dateTime.year().month().day())
            .font(.callout)
            .foregroundStyle(.secondary)
        }
        
        CardListItem {
          Text("Distance")
            .font(.callout)
            .fontWeight(.semibold)
          
          Spacer()
          
          Text("\(category.description) (\(RaceDistanceType(rawValue: viewModel.medal.raceCategory.type)!.displayName))")
            .font(.callout)
            .foregroundStyle(.secondary)
        }
        
        CardListItem {
          Text("Result")
            .font(.callout)
            .fontWeight(.semibold)
          
          Spacer()
          
          if let result = viewModel.medal.result {
            Text(result)
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
        }
      } // CardSection
      
      CardSection(title: "Notes") {
        CardListItem {
          if let note = viewModel.medal.note, !note.isEmpty {
            Text(note)
              .font(.body)
              .foregroundStyle(.primary)
          } else {
            Text("No notes")
              .font(.subheadline)
              .foregroundStyle(.secondary)
          }
        }
      } // CardSection
    } // ScrollView
    .padding(.horizontal)
    .background(.ultraThinMaterial)
    .navigationTitle(viewModel.medal.title)
    .navigationBarTitleDisplayMode(.inline)
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
        } // Menu
      } // ToolbarItem
    } // toolbar
    .alert(isPresented: $isShowDeleteConfirm) {
      .deleteConfirmation(name: viewModel.medal.title, onDelete: {
        do {
          try viewModel.attachContext(modelContext)
          try viewModel.deleteMedal(viewModel.medal)
          dismiss()
        } catch {
          errorWrapper = ErrorWrapper(error: AppError.unknown)
        }
      })
    }
    .sheet(isPresented: $isShowEditor) {
      NavigationStack {
        MedalEditView(medal: viewModel.medal)
      }
    }
    .sheet(item: $errorWrapper, onDismiss: nil) { wrapper in
      ErrorView(errorWrapper: wrapper)
    }
  }
}

#Preview(traits: .sampleData) {
  MedalDetailView(medal: Medal.sampleData.first!)
}
