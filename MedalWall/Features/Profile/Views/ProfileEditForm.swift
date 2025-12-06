//
//  ProfileEditForm.swift
//  MedalWall
//
//  Created by Quien on 2025-12-04.
//

import SwiftUI
import PhotosUI

struct ProfileEditForm: View {
  @Environment(\.modelContext) private var modelContext
  @Environment(\.dismiss) private var dismiss
  @State private var selectedAvatarItem: PhotosPickerItem?
  @State private var isDateSet: Bool = false
  @State private var errorWrapper: ErrorWrapper?
  @State private var viewModel: ProfileEditViewModel
  
  init(profile: User?) {
    self._viewModel = State(initialValue: ProfileEditViewModel(profile: profile))
  }
  
  var body: some View {
    Form {
      Section("Avatar") {
        ZStack {
          if let uiImage = viewModel.avatar {
            Image(uiImage: uiImage)
              .avatar()
              .foregroundStyle(.gray)
          } else {
            Image(systemName: "photo.circle.fill")
              .avatar()
              .foregroundStyle(.gray)
          }
        }
        .frame(maxWidth: .infinity)
        
        PhotosPicker(
          selection: $selectedAvatarItem,
          matching: .images,
          photoLibrary: .shared()
        ) {
          HStack(alignment: .center) {
            Text("Pcik Photo")
              .font(.headline)
              .frame(maxWidth: .infinity)
              .foregroundStyle(.white)
              .padding()
              .background(.primary)
              .clipShape(.rect(cornerRadius: 12))
          }
        }
        .onChange(of: selectedAvatarItem) { _, newItem in
          guard let newItem else { return }
          
          Task {
            do {
              if let data = try await newItem.loadTransferable(type: Data.self),
                 let image = UIImage(data: data) {
                viewModel.avatarData = data
                viewModel.avatar = image
              } else {
                errorWrapper = ErrorWrapper(error: AppError.photoDataInvalid)
              }
            } catch {
              errorWrapper = ErrorWrapper(error: AppError.photoLoadFailed)
            }
          } // Task
        } // onChange
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
                .clipShape(.rect(cornerRadius: 12))
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
      
      Section("Other") {
        Picker("Measurement Unit", selection: $viewModel.unit) {
          ForEach(MeasurementUnit.allCases, id: \.self) { unit in
            Text(unit.displayName).tag(unit)
          }
        }
        .pickerStyle(.navigationLink)
      } // Section
    } // Form
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
            try viewModel.attachContext(modelContext)
            try viewModel.save()
            dismiss()
          } catch {
            errorWrapper = ErrorWrapper(error: AppError.userSaveFailed)
          }
        }
        .disabled(!viewModel.isFormValid)
      }
    } // toolbar
  }
}

#Preview {
  ProfileEditForm(profile: User.defaultUser)
}
