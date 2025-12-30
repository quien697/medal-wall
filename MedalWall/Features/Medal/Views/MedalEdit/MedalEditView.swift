//
//  MedalEditView.swift
//  MedalWall
//
//  Created by Quien on 2025-12-21.
//

import SwiftUI
import PhotosUI
import SwiftData

struct MedalEditView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var selectedPhotoItem: PhotosPickerItem?
  @State private var errorWrapper: ErrorWrapper?
  @State private var showPhotosPicker: Bool = false
  @State private var isShowingPhotoDialog: Bool = false
  @State private var viewModel: MedalEditViewModel
  
  @Query(sort: \Race.date, animation: .default) private var races: [Race]
  
  private let size: CGFloat = 160
  
  init(medal: Medal? = nil, user: User? = nil) {
    self._viewModel = State(initialValue: MedalEditViewModel(medal: medal, user: user))
  }
  
  var body: some View {
    Form {
      Section("Photo") {
        ZStack(alignment: .center) {
          Hexagon()
            .fill(
              LinearGradient(
                colors: [
                  .orange.opacity(0.8),
                  .orange.opacity(0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
              )
            )
            .stroke(.black.opacity(0.1), lineWidth: 2)
            .frame(width: size, height: size)
          
          if let uiImage = viewModel.photo {
            Image(uiImage: uiImage)
              .resizable()
              .scaledToFill()
              .frame(width: size * 0.7, height: size * 0.7)
              .clipShape(Circle())
              .shadow(radius: 4)
          } else {
            Image(systemName: "medal.fill")
              .font(.system(size: size * 0.3, weight: .semibold))
              .foregroundColor(.white)
          }
        }
        .frame(maxWidth: .infinity)
        
        Button {
          isShowingPhotoDialog = true
        } label: {
          Label("Edit Photo", systemImage: "photo")
            .font(.headline)
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
            .padding()
            .background(.primary)
            .clipShape(.rect(cornerRadius: 12))
        }
      } // Section
      
      Section("Medal Info") {
        TextField("Title", text: $viewModel.title)
        
        DatePicker("Date", selection: $viewModel.date, displayedComponents: .date)
      }
      
      Section("Race Info") {
        Picker(
          "Race",
          selection: Binding(get: {
            viewModel.selectedRaceID ?? races.first?.id
          }, set: { raceId in
            viewModel.selectedRaceID = raceId
            
            if let id = raceId,
               let race = races.first(where: { $0.id == id }),
               let firstCategory = race.categories.first {
              viewModel.selectedRaceCategoryID = firstCategory.id
            } else {
              viewModel.selectedRaceCategoryID = nil
            }
          })) {
            ForEach(races, id: \.id) { race in
              Text(race.name).tag(race.id as UUID?)
            }
          }
          .pickerStyle(.navigationLink)
        
        Picker("Category", selection: Binding(get: {
          viewModel.selectedRaceCategoryID
        }, set: { new in
          viewModel.selectedRaceCategoryID = new
        })) {
          let availableCategories = races.first(where: { $0.id == viewModel.selectedRaceID })?.categories ?? []
          
          ForEach(availableCategories, id: \.id) { cat in
            Text("\(cat.name) (\(cat.type))").tag(cat.id as UUID?)
          }
        }
        .pickerStyle(.navigationLink)
        
        // Result, will implement later
      }
      
      Section("Notes") {
        TextEditor(text: $viewModel.note)
          .frame(minHeight: 100)
      }
    }
    .navigationTitle(viewModel.isNewMedal ? "Add Medal" : "Edit Medal")
    .navigationBarTitleDisplayMode(.inline)
    .toolbar {
      ToolbarItem(placement: .cancellationAction) {
        Button("Cancel") { dismiss() }
      }
      
      ToolbarItem(placement: .confirmationAction) {
        Button(viewModel.isNewMedal ? "Add" : "Save") {
          do {
            try viewModel.save(in: modelContext)
            dismiss()
          } catch {
            errorWrapper = ErrorWrapper(error: AppError.unknown)
          }
        }
        .disabled(!viewModel.isFormValid)
      }
    } // toolbar
    .sheet(item: $errorWrapper) { wrapper in
      ErrorView(errorWrapper: wrapper)
    }
    .confirmationDialog(
      "Edit Photo",
      isPresented: $isShowingPhotoDialog,
      titleVisibility: .visible
    ) {
      Button("Choose from Library") {
        showPhotosPicker = true
      }
      
      Button("Remove Photo", role: .destructive) {
        viewModel.clearPhoto()
        selectedPhotoItem = nil
      }
      
      Button("Cancel", role: .cancel) { isShowingPhotoDialog = false }
    } // confirmationDialog
    .photosPicker(isPresented: $showPhotosPicker, selection: $selectedPhotoItem)
    .onChange(of: selectedPhotoItem) { _, newItem in
      guard let newItem else { return }
      
      Task {
        do {
          if let data = try await newItem.loadTransferable(type: Data.self) {
            viewModel.updatePhoto(with: data)
          } else {
            errorWrapper = ErrorWrapper(error: AppError.photoDataInvalid)
          }
        } catch {
          errorWrapper = ErrorWrapper(error: AppError.photoLoadFailed)
        }
      }
    } // onChange
    .onAppear {
      // Ensure default race/category selection for new medals
      if viewModel.isNewMedal {
        if viewModel.selectedRaceID == nil {
          viewModel.selectedRaceID = races.first?.id
        }
        if viewModel.selectedRaceCategoryID == nil, let rid = viewModel.selectedRaceID,
           let race = races.first(where: { $0.id == rid }), let firstCat = race.categories.first {
          viewModel.selectedRaceCategoryID = firstCat.id
        }
      }
    }
  }
}

#Preview {
  // Provide a sample user for preview
  MedalEditView(medal: Medal.sampleData.first!)
}
