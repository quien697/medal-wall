//
//  RaceEditView.swift
//  MedalWall
//
//  Created by Quien on 2025-10-30.
//

import SwiftUI
import PhotosUI
import SwiftData

enum Mode { case add, edit }

struct RaceEditView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var selectedRacePhotoItem: PhotosPickerItem?
  @State private var newRaceDistance = RaceDistance.default
  @State private var isShowRaceDistanceAddView = false
  @State private var saveRaceErrorWrapper: ErrorWrapper?
  @State private var addDistanceErrorWrapper: ErrorWrapper?
  @State private var viewModel: RaceEditViewModel
  
  init(race: Race?) {
    self._viewModel = State(initialValue: RaceEditViewModel(race: race))
  }
  
  var body: some View {
    Form {
//      Section("Race Image") {
//        PhotosPicker(
//          selection: $selectedRacePhotoItem,
//          matching: .images,
//          photoLibrary: .shared()
//        ) {
//          if let uiImage = viewModel.photo {
//            Image(uiImage: uiImage)
//              .resizable()
//              .scaledToFill()
//              .clipShape(.rect(cornerRadius: 12))
//              .overlay(alignment: .topTrailing) {
//                Button {
//                  selectedRacePhotoItem = nil
//                  viewModel.clearPhoto()
//                } label: {
//                  Image(systemName: "xmark.circle.fill")
//                    .font(.system(size: 32))
//                    .symbolRenderingMode(.hierarchical)
//                    .foregroundStyle(.white)
//                    .shadow(radius: 2)
//                }
//                .padding()
//              }
//          } else {
//            ContentUnavailableView {
//              Image(systemName: "photo.fill")
//                .resizable()
//                .scaledToFit()
//                .frame(width: 60)
//                .padding(.bottom, 10)
//              
//              Text("Add Photo")
//                .font(.headline)
//            }
//            .background(.thinMaterial)
//            .frame(height: 250)
//            .overlay(
//              RoundedRectangle(cornerRadius: 12)
//                .stroke(Color.blue, style: StrokeStyle(lineWidth: 2, dash: [10, 2]))
//            )
//          }
//        } // PhotosPicker
//        .onChange(of: selectedRacePhotoItem) { _, newItem in
//          guard let newItem else { return }
//          
//          Task {
//            if let data = try await newItem.loadTransferable(type: Data.self) {
//              viewModel.updatePhoto(with: data)
//            }
//          }
//        } // onChange
//      }
      
      RacePhotoSection(
        data: $viewModel.photoData,
        image: $viewModel.photo
      )
      
      RaceInfoSection(viewModel: viewModel)
      
      RaceLocationSection(viewModel: viewModel)
      
      RaceDistanceSection(
        viewModel: viewModel,
        isPresented: $isShowRaceDistanceAddView
      )
      
      RaceAdditionalSection(viewModel: viewModel)
    } // Form
    .task {
      viewModel.attachContext(modelContext)
    }
    .navigationTitle("\(viewModel.isNewRace ? "Add" : "Edit") Race")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") {
          dismiss()
        }
      } // ToolbarItem
      
      ToolbarItem(placement: .confirmationAction) {
        Button(viewModel.isNewRace ? "Add" : "Save") {
          do {
            try viewModel.save()
            dismiss()
          } catch {
            saveRaceErrorWrapper = ErrorWrapper(error: error, guidance: "Race event was not recorded. Try again later.")
          }
        }
        .disabled(!viewModel.isFormValid)
      } // ToolbarItem
    } // toolbar
    .sheet(isPresented: $isShowRaceDistanceAddView) {
      RaceDistanceAddView(onSave: { newDistance in
        do {
          try viewModel.addDistance(newDistance)
        } catch {
          addDistanceErrorWrapper = ErrorWrapper(error: error, guidance: "Duplicate distance found. Please choose a different distance.")
        }
      })
    }
    .sheet(item: $saveRaceErrorWrapper) {
      dismiss()
    } content: { wrapper in
      ErrorView(errorWrapper: wrapper)
    }
    .sheet(item: $addDistanceErrorWrapper, onDismiss: nil) { wrapper in
      ErrorView(errorWrapper: wrapper)
    } // sheet
  }
}

#Preview(traits: .sampleData) {
  @Previewable @Query(sort: \Race.date) var races: [Race]
  
  NavigationStack {
    RaceEditView(race: races.first!)
  }
}
