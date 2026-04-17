//
//  EditMedalView.swift
//  MedalWall
//
//  Created by Quien on 2026-04-09.
//

import SwiftUI
import PhotosUI
import SwiftData

struct EditMedalView: View {
  // MARK: - Environment
  @Environment(UserManager.self) private var userManager
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  // MARK: - State
  @State private var viewModel: EditMedalViewModel
  @State private var errorWrapper: ErrorWrapper?
  @State private var isPresentingPhotoPicker: Bool = false
  @State private var isPresentingCropImageView: Bool = false
  @State private var isPresentingDistancePicker: Bool = false
  @State private var selectedPhoto: PhotosPickerItem?
  @State private var shouldDismiss: Bool = false
  @State private var isPresentingRaceEntryPicker: Bool = false
  
  init(mode: ItemEditMode, medal: Medal? = nil) {
    self._viewModel = State(initialValue: EditMedalViewModel(mode: mode, medal: medal))
  }
  
  var body: some View {
    NavigationStack {
      VStack {
        EditMedalPhotoPicker(
          photo: viewModel.cropPhoto ?? viewModel.photo,
          onChooseFromLibrary: {
            isPresentingPhotoPicker = true
          },
          onCrop: {
            isPresentingCropImageView = true
          },
          onRemove: {
            selectedPhoto = nil
            viewModel.clearPhoto()
          }
        )
        
        EditMedalAutoFillSection {
          isPresentingRaceEntryPicker = true
        }
        
        Form {
          EditMedalResultSection(finishTime: $viewModel.finishTime)
          
          EditMedalInfoSection(
            name: $viewModel.name,
            date: $viewModel.date,
            bib: $viewModel.bibNumber,
            distance: viewModel.distance.displayLabel,
            onEditDistance: {
              isPresentingDistancePicker = true
            }
          )
          
          EditMedalLocationSection(
            country: $viewModel.country,
            province: $viewModel.province,
            city: $viewModel.city,
            district: $viewModel.district
          )
          
          EditMedalPlacementSection(
            overallPlacement: $viewModel.overallPlacement,
            totalParticipants: $viewModel.totalParticipants,
            genderPlacement: $viewModel.genderPlacement,
            genderTotal: $viewModel.genderTotal,
            division: $viewModel.division,
            divisionPlacement: $viewModel.divisionPlacement,
            divisionTotal: $viewModel.divisionTotal
          )
          
          EditMedalNoteSection(note: $viewModel.note)
        } // Form
      } // VStack
      .navigationTitle("\(viewModel.mode == .add ? "New" : "Edit") Medal")
      .navigationBarTitleDisplayMode(.inline)
      .scrollContentBackground(.hidden)
      .background(Color.Background.primary)
      .toolbar {
        ToolbarItem(placement: .cancellationAction) {
          Button(role: .close) {
            dismiss()
          }
        } // ToolbarItem
        
        ToolbarItem(placement: .confirmationAction) {
          Button(role: .confirm) {
            guard let user = userManager.currentUser else {
              errorWrapper = ErrorWrapper(error: AppError.userLoadFailed)
              return
            }
            
            do {
              try viewModel.save(by: user)
              dismiss()
            } catch {
              shouldDismiss = true
              errorWrapper = ErrorWrapper(error: AppError.unknown)
            }
          }
          .disabled(!viewModel.isFormValid)
        } // ToolbarItem
      } // toolbar
      .onAppear {
        viewModel.configure(context: modelContext)
      }
      .photosPicker(
        isPresented: $isPresentingPhotoPicker,
        selection: $selectedPhoto,
        matching: .images
      )
      .onChange(of: selectedPhoto) { _, newItem in
        guard let newItem else { return }
        
        Task {
          do {
            if let data = try await newItem.loadTransferable(type: Data.self) {
              viewModel.clearPhoto()
              viewModel.updatePhoto(with: data)
            } else {
              errorWrapper = ErrorWrapper(error: AppError.photoDataInvalid)
            }
          } catch {
            errorWrapper = ErrorWrapper(error: AppError.photoLoadFailed)
          }
        }
      }
      .sheet(isPresented: $isPresentingCropImageView) {
        CropImageView(
          image: viewModel.photo,
          type: .medal,
        ) { croppedImage in
          if let croppedImage {
            viewModel.updateCropPhoto(with: croppedImage)
          }
        }
      }
      .sheet(isPresented: $isPresentingDistancePicker) {
        DistanceEditView(
          mode: .edit,
          distance: viewModel.distance,
          onAction: { newDistance in
            viewModel.distance = newDistance
          }
        )
        .presentationDetents([.medium])
      }
      .sheet(isPresented: $isPresentingRaceEntryPicker) {
        RaceEntryPicker { selection in
          viewModel.autoFill(from: selection)
        }
      }
      .sheet(item: $errorWrapper, onDismiss: {
        if shouldDismiss {
          dismiss()
        }
      }) { wrapper in
        ErrorView(errorWrapper: wrapper)
      }
    } // NavigationStack
  }
}

#Preview("Add mode") {
  @Previewable @Environment(\.modelContext) var modelContext
  
  NavigationStack {
    EditMedalView(mode: .add)
  }
  .environment(UserManager(modelContext: modelContext))
}

#Preview("Edit mode") {
  @Previewable @Environment(\.modelContext) var modelContext
  
  NavigationStack {
    EditMedalView(mode: .edit, medal: Medal.sampleData.first!)
  }
  .environment(UserManager(modelContext: modelContext))
}
