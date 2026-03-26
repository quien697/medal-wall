//
//  RaceEditionEditView.swift
//  MedalWall
//
//  Created by Quien on 2026-03-24.
//

import SwiftUI
import PhotosUI
import SwiftData

enum RaceEditionEditMode { case add, edit }

struct RaceEditionEditView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(UserManager.self) private var userManager
  @Environment(\.dismiss) private var dismiss
  @State private var isShowingPhotoDialog: Bool = false
  @State private var isShowingPhotoPicker: Bool = false
  @State private var isShowingCropImageView: Bool = false
  @State private var selectedPhotoItem: PhotosPickerItem?
  @State private var viewModel: RaceEditionEditViewModel
  let onUpdate: (RaceEdition) -> Void
  
  init(
    mode: RaceEditionEditMode,
    race: Race,
    edition: RaceEdition?,
    onUpdate: @escaping (RaceEdition) -> Void
  ) {
    self.onUpdate = onUpdate
    self._viewModel = State(initialValue: RaceEditionEditViewModel(mode: mode, race: race, edition: edition))
  }
  
  var body: some View {
    Form {
      Section("Logo") {
        HStack(spacing: 15) {
          Group {
            if let uiImage = viewModel.cropPhoto ?? viewModel.photo {
              Image(uiImage: uiImage)
                .styled(as: .raceThumbnail)
            } else {
              Image(systemName: "camera.fill")
                .placeholderStyled(as: .raceThumbnail)
            }
          } // Group
          .confirmationDialog(
            "Edit Photo",
            isPresented: $isShowingPhotoDialog,
            titleVisibility: .visible
          ) {
            Button("Choose from Library") {
              isShowingPhotoPicker = true
            }
            
            if viewModel.cropPhoto != nil || viewModel.photo != nil {
              Button("Crop Photo") {
                isShowingCropImageView = true
              }
            }
            
            Button("Remove Photo", role: .destructive) {
              selectedPhotoItem = nil
              viewModel.clearPhoto()
            }
            
            Button("Cancel", role: .cancel) {
              isShowingPhotoDialog = false
            }
          } // confirmationDialog
          
          VStack(alignment: .leading, spacing: 5) {
            Text("Logo")
              .font(.headline)
            
            Text("(Optional) Leave empty to use race logo")
              .font(.caption)
              .foregroundStyle(Color.Text.tertiary)
          } // VStack
          
          Spacer()
          
          Button("\(viewModel.photo == nil && viewModel.cropPhoto == nil ? "Add" : "Edit")") {
            isShowingPhotoDialog = true
          }
          .goldFillButtonStyle()
        } // HStack
      } // Section
      
      Section("Date") {
        Toggle(isOn: Binding(
          get: { viewModel.isOneDay },
          set: { _ in viewModel.toggleOneDay() }
        )) {
          Text("One Day Event")
            .fontWeight(.bold)
            .foregroundStyle(Color.Text.tertiary)
        }
        .tint(Color.Badge.Gold.primary)
        
        Picker(selection: Binding(
          get: { viewModel.year },
          set: { viewModel.updateYear($0) }
        )) {
          ForEach((1911...2090).reversed(), id: \.self) { year in
            Text(String(year))
              .font(.body)
              .tag(year)
          }
        } label: {
          Text("Year")
            .fontWeight(.bold)
            .foregroundStyle(Color.Text.tertiary)
        }
        .tint(Color.Text.primary)
        
        DatePicker(
          selection: Binding(
            get: { viewModel.startDate },
            set: { viewModel.updateStartDate($0) }
          ),
          in: viewModel.yearDateRange,
          displayedComponents: [.date]
        ) {
          Text("Start Date")
            .fontWeight(.bold)
            .foregroundStyle(Color.Text.tertiary)
        }
        .tint(Color.Badge.Gold.primary)
        
        if !viewModel.isOneDay {
          DatePicker(
            selection: $viewModel.endDate,
            in: viewModel.minEndDate...viewModel.maxEndDate,
            displayedComponents: [.date]
          ) {
            Text("End Date")
              .fontWeight(.bold)
              .foregroundStyle(Color.Text.tertiary)
          }
          .tint(Color.Badge.Gold.primary)
        }
      } // Section
      
      Section("Distnaces") {
        // distances
      }
    } // Form
    .navigationTitle("\(viewModel.mode == .add ? "Add" : "Edit") Edition")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .topBarTrailing) {
        Button("Update") {
          if let userId = userManager.currentUserID {
            let updatedEdition = viewModel.onSave(by: userId)
            onUpdate(updatedEdition)
            dismiss()
          } else {
            // handle error
          }
        }
        .disabled(!viewModel.isFormValid)
      }
    }
    .photosPicker(
      isPresented: $isShowingPhotoPicker,
      selection: $selectedPhotoItem,
      matching: .images
    )
    .onChange(of: selectedPhotoItem) { _, newItem in
      guard let newItem else { return }

      Task {
        do {
          if let data = try await newItem.loadTransferable(type: Data.self) {
            viewModel.clearPhoto()
            viewModel.updatePhoto(with: data)
          } else {
//            errorWrapper = ErrorWrapper(error: AppError.photoDataInvalid)
          }
        } catch {
//          errorWrapper = ErrorWrapper(error: AppError.photoLoadFailed)
        }
      } // Task
    }
    .sheet(isPresented: $isShowingCropImageView) {
      CropImageView(
        image: viewModel.photo,
        type: .raceHero,
      ) { cropppedImage in
        if let cropppedImage {
          viewModel.updateCropPhoto(with: cropppedImage)
        }
      }
    }
    
    //    .sheet(isPresented: $isShowingAddDistanceSheet) {
    //      NavigationStack {
    //        RaceDistanceEditView(
    //          mode: .add,
    //          distance: .default,
    //          onUpdate: { newDistance in
    //            do {
    //              try viewModel.addDistance(newDistance)
    //            } catch {
    //              errorWrapper = ErrorWrapper(
    //                error: error,
    //                guidance: "This distance already exists for this edition."
    //              )
    //            }
    //          }
    //        )
    //      }
    //      .presentationDetents([.medium])
    //    }
    //    .sheet(item: $editingDistance) { distance in
    //      NavigationStack {
    //        RaceDistanceEditView(
    //          mode: .edit,
    //          distance: distance,
    //          onUpdate: { updatedDistance in
    //            do {
    //              try viewModel.updateDistance(old: distance, with: updatedDistance)
    //            } catch {
    //              errorWrapper = ErrorWrapper(
    //                error: error,
    //                guidance: "This distance already exists for this edition."
    //              )
    //            }
    //          }
    //        )
    //      }
    //      .presentationDetents([.medium])
    //    }
  }
}

#Preview("Add Mode") {
  NavigationStack {
    RaceEditionEditView(
      mode: .add,
      race: Race.sampleData.first!,
      edition: nil,
      onUpdate: { _ in }
    )
  }
}

#Preview("Edit Mode") {
  NavigationStack {
    RaceEditionEditView(
      mode: .edit,
      race: Race.sampleData.first!,
      edition: Race.sampleData.first!.editions.first!,
      onUpdate: { _ in }
    )
  }
}

