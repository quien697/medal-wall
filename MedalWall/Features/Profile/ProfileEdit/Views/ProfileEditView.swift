//
//  ProfileEditView.swift
//  MedalWall
//
//  Created by Quien on 2025-12-04.
//

import SwiftUI
import PhotosUI
import SwiftData

struct ProfileEditView: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var isShowingPhotosPicker: Bool = false
  @State private var isShowingPhotoDialog: Bool = false
  @State private var isShowingCropImageView: Bool = false
  @State private var selectedPhotoItem: PhotosPickerItem?
  @State private var errorWrapper: ErrorWrapper?
  @State private var viewModel: ProfileEditViewModel
  
  init(profile: User?) {
    self._viewModel = State(initialValue: ProfileEditViewModel(profile: profile))
  }
  
  var body: some View {
    Form {
      Section("Avatar") {
        AvatarImage(
          photo: viewModel.avatar,
          cropPhoto: viewModel.cropAvatar
        )
          .frame(maxWidth: .infinity)
          .confirmationDialog(
            "Edit Photo",
            isPresented: $isShowingPhotoDialog,
            titleVisibility: .visible
          ) {
            Button("Choose from Library") {
              isShowingPhotosPicker = true
            }
            
            if selectedPhotoItem != nil || viewModel.avatar != nil {
              Button("Crop Photo") {
                isShowingCropImageView = true
              }
            }
            
            Button("Remove Photo", role: .destructive) {
              viewModel.clearPhoto()
              selectedPhotoItem = nil
            }
            
            Button("Cancel", role: .cancel) { isShowingPhotoDialog = false }
          } // confirmationDialog
        
        Button {
          isShowingPhotoDialog = true
        } label: {
          Label("Edit Photo", systemImage: "photo")
            .font(.headline)
            .frame(maxWidth: .infinity)
            .foregroundStyle(.white)
            .padding()
            .background(.primary)
            .clipShape(.rect(cornerRadius: 16))
        }
      } // Section
      
      Section("User Name") {
        TextField("First Name", text: $viewModel.userName.firstName)
        TextField("Last Name", text: $viewModel.userName.lastName)
      }
      
      Section("Bio") {
        TextEditor(text: $viewModel.bio)
          .frame(minHeight: 100)
      }
      
      Section("Profile Info") {
        Picker("Gender", selection: $viewModel.gender) {
          Text("Not Set").tag(Gender?.none)
          
          ForEach(Gender.allCases, id: \.self) { gender in
            Text(gender.displayName).tag(gender)
          }
        }
        .pickerStyle(.navigationLink)
        
        HStack {
          Text("Birthday")
          
          Spacer()
          
          if viewModel.isBirthdaySet {
            DatePicker("Date", selection: $viewModel.birthday, displayedComponents: .date)
          } else {
            Button {
              viewModel.isBirthdaySet = true
            } label: {
              Text("Not Set")
                .padding(.horizontal, 30)
                .padding(.vertical, 6)
                .background(.blue)
                .foregroundStyle(.white)
                .clipShape(.rect(cornerRadius: 16))
            }
          }
        }
        .swipeActions {
          Button("Clear") {
            viewModel.isBirthdaySet = false
            viewModel.birthday = .now
          }
        }
      } // Section
    } // Form
    .onAppear {
      viewModel.configure(context: modelContext)
    }
    .toolbar {
      if viewModel.isNewProfile {
        ToolbarItem(placement: .cancellationAction) {
          Button("Cancel") {
            dismiss()
          }
        }
      }
      
      ToolbarItem(placement: .topBarTrailing) {
        Button(viewModel.isNewProfile ? "Add" : "Save") {
          do {
            try viewModel.save()
            dismiss()
          } catch {
            errorWrapper = ErrorWrapper(error: AppError.userSaveFailed)
          }
        }
        .disabled(!viewModel.isFormValid)
      }
    } // toolbar
    .photosPicker(isPresented: $isShowingPhotosPicker, selection: $selectedPhotoItem)
    .onChange(of: selectedPhotoItem) { _, newItem in
      guard let newItem else { return }
      
      Task {
        if let data = try await newItem.loadTransferable(type: Data.self) {
          viewModel.clearPhoto()
          viewModel.updatePhoto(with: data)
        } else {
          errorWrapper = ErrorWrapper(error: AppError.photoDataInvalid)
        }
      }
    } // onChange
    .sheet(isPresented: $isShowingCropImageView) {
      CropImageView(
        image: viewModel.avatar,
        type: .avatar
      ) { cropppedImage in
        if let cropppedImage {
          viewModel.updateCropPhoto(with: cropppedImage)
        }
      }
    }
    .sheet(item: $errorWrapper, onDismiss: {
      dismiss()
    }) { wrapper in
      ErrorView(errorWrapper: wrapper)
    }
  }
}

#Preview {
  ProfileEditView(profile: User.defaultUser)
}
