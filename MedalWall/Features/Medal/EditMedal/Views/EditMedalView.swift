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
  @State private var isPresentingDistancePicker: Bool = false
  @State private var isPresentingCropImageView: Bool = false
  @State private var isPresentingRaceEntryPicker: Bool = false
  @State private var shouldDismiss: Bool = false
  // Medal photo picker
  @State private var isPresentingPhotoPicker: Bool = false
  @State private var selectedPhoto: PhotosPickerItem?
  @State private var rawPickedImage: UIImage?
  // Event photos picker
  @State private var isPresentingEventPhotosPicker: Bool = false
  @State private var selectedEventPhotos: [PhotosPickerItem] = []
  
  init(mode: ItemEditMode, medal: Medal? = nil) {
    self._viewModel = State(initialValue: EditMedalViewModel(mode: mode, medal: medal))
  }
  
  var body: some View {
    NavigationStack {
      Form {
        EditPhotoPicker(
          photo: viewModel.photo,
          hint: "Tap to \(viewModel.photo == nil ? "add a new" : "update the") medal photo",
          photoView: {
            MedalImage(photo: viewModel.photo)
          },
          onChooseFromLibrary: {
            isPresentingPhotoPicker = true
          },
          onRemove: {
            selectedPhoto = nil
            rawPickedImage = nil
            viewModel.clearPhoto()
          }
        )
        .listRowInsets(EdgeInsets())
        .listRowBackground(Color.clear)
        
        EditMedalAutoFillSection {
          isPresentingRaceEntryPicker = true
        }
        
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
        
        EditMedalEventPhotosSection(
          photos: viewModel.draftEventPhotos,
          onChooseFromLibrary: {
            isPresentingEventPhotosPicker = true
          },
          onRemove: {
            viewModel.removeEventPhoto(id: $0)
          }
        )
        
        EditMedalTagsSection(tags: $viewModel.tags)
      } // Form
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
            guard let userID = userManager.currentUserID else {
              errorWrapper = ErrorWrapper(error: AppError.userLoadFailed)
              return
            }
            
            do {
              try viewModel.save(by: userID)
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
          if let data = try? await newItem.loadTransferable(type: Data.self),
             let uiImage = UIImage(data: data) {
            rawPickedImage = uiImage
            isPresentingCropImageView = true
          } else {
            errorWrapper = ErrorWrapper(error: AppError.photoDataInvalid)
          }
        }
      }
      .photosPicker(
        isPresented: $isPresentingEventPhotosPicker,
        selection: $selectedEventPhotos,
        maxSelectionCount: 10,
        matching: .images
      )
      .onChange(of: selectedEventPhotos) { _, newItems in
        guard !newItems.isEmpty else { return }
        
        Task {
          var dataList: [Data] = []
          
          for item in newItems {
            if let data = try? await item.loadTransferable(type: Data.self) {
              dataList.append(data)
            } else {
              errorWrapper = ErrorWrapper(error: AppError.photoDataInvalid)
            }
          }
          
          if !dataList.isEmpty {
            viewModel.addEventPhotos(dataList)
          }
          
          selectedEventPhotos = []
        }
      }
      .sheet(isPresented: $isPresentingCropImageView, onDismiss: {
        selectedPhoto = nil
        rawPickedImage = nil
      }) {
        CropImageView(
          image: rawPickedImage,
          cropShape: .circle
        ) { croppedImage in
          if let croppedImage {
            viewModel.updatePhoto(with: croppedImage)
          }
        }
      }
      .sheet(isPresented: $isPresentingDistancePicker) {
        EditDistanceView(
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

#Preview {
  NavigationStack {
    EditMedalView(mode: .edit, medal: Medal.sampleData.first!)
  }
  .environment(UserManager())
}
