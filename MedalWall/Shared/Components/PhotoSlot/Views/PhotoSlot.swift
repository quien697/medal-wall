//
//  PhotoSlot.swift
//  MedalWall
//
//  Created by Quien on 2026-11-12.
//

import CropImage
import PhotosUI
import SwiftUI

/// A photo the user sets in a form: the photo, a stored photo still downloading or that could not
/// be downloaded, or a dashed slot inviting one.
///
/// Tapping it opens an alert under `title`, with `message` beneath when given: Choose Photo,
/// Take Photo while `offersCamera` is true, Remove Photo while it holds a photo, shown or not,
/// and Cancel.
/// Choose Photo opens the photo library. Take Photo opens the camera once camera access allows
/// it, lets iOS ask first, or says why the camera cannot open. Either photo is then cropped to
/// `cropShape`. The crop screen stays open, showing progress, while the cropped photo's size is
/// checked: a photo under the limit then reaches `onPick` and the crop screen closes, and one
/// too large to upload is refused over the crop screen, which stays open so the user can crop
/// closer. A picked photo that fails to load reaches `onError`.
///
/// The slot wears a 2 pt ink ring while its alert is open. It is drawn at its `imageType`'s
/// size, shrinking to the width it is given.
struct PhotoSlot: View {
  // MARK: - Environment
  @Environment(\.openURL) private var openURL

  // MARK: - State
  @State private var isPresentingOptions = false
  @State private var isPresentingPhotoPicker = false
  @State private var selectedPhoto: PhotosPickerItem?
  @State private var cropErrorWrapper: ErrorWrapper?
  @State private var viewModel = PhotoSlotViewModel()

  // MARK: - Properties
  private let content: PhotoSlotContent
  private let imageType: ImageType
  private let cropShape: CropShape
  private let title: LocalizedStringKey
  private let message: LocalizedStringKey?
  private let placeholderText: LocalizedStringKey?
  private let offersCamera: Bool
  private let onPick: (CroppedPhoto) -> Void
  private let onRemove: () -> Void
  private let onError: (AppError) -> Void

  // MARK: - Init
  /// Creates a slot showing `content`: the form's photo, its stored photo's status, or the
  /// dashed slot reading `placeholderText` beneath a plus.
  init(
    content: PhotoSlotContent,
    imageType: ImageType,
    cropShape: CropShape,
    title: LocalizedStringKey,
    message: LocalizedStringKey? = nil,
    placeholderText: LocalizedStringKey? = nil,
    offersCamera: Bool = true,
    onPick: @escaping (CroppedPhoto) -> Void,
    onRemove: @escaping () -> Void,
    onError: @escaping (AppError) -> Void
  ) {
    self.content = content
    self.imageType = imageType
    self.cropShape = cropShape
    self.title = title
    self.message = message
    self.placeholderText = placeholderText
    self.offersCamera = offersCamera
    self.onPick = onPick
    self.onRemove = onRemove
    self.onError = onError
  }

  // MARK: - Body
  var body: some View {
    Button {
      isPresentingOptions = true
    } label: {
      Color.clear
        .aspectRatio(imageType.size.width / imageType.size.height, contentMode: .fit)
        .frame(maxWidth: imageType.size.width)
        .overlay {
          switch content {
          case .photo(let photo):
            Image(uiImage: photo)
              .resizable()
              .scaledToFill()
              .background(Color.Surface.primary)
          case .loading:
            ProgressView()
          case .failed:
            VStack(spacing: .Space.inline) {
              Image(systemName: "exclamationmark.triangle")
                .font(.TypeScale.title2)

              Text("Couldn't load")
                .font(.TypeScale.caption)
            }  // VStack
            .foregroundStyle(Color.Text.secondary)
          case .empty:
            EmptyView()
          }
        }
        .clipShape(imageType.shape)
        .contentShape(imageType.shape)
        .overlay {
          if content.holdsPhoto {
            imageType.shape.stroke(Color.Border.primary, lineWidth: 1)
          } else {
            EmptyPhotoSlot(as: imageType, text: placeholderText)
          }
        }
        .overlay {
          if isPresentingOptions {
            imageType.shape.stroke(Color.Accent.primary, lineWidth: 2)
          }
        }
    }  // Button
    .buttonStyle(.plain)
    .accessibilityLabel(
      PhotoSlotViewModel.accessibilityLabel(
        content: content, title: title, placeholderText: placeholderText)
    )
    .alert(Text(title), isPresented: $isPresentingOptions) {
      Button("Choose Photo") {
        isPresentingPhotoPicker = true
      }  // Button

      if offersCamera {
        Button("Take Photo") {
          viewModel.takePhoto()
        }  // Button
      }

      if content.holdsPhoto {
        Button("Remove Photo", role: .destructive) {
          onRemove()
        }  // Button
      }

      Button("Cancel", role: .cancel) {}
    } message: {
      if let message {
        Text(message)
      }
    }  // alert
    .alert("Allow Camera Access", isPresented: $viewModel.isPresentingCameraSettings) {
      Button("Open Settings") {
        if let url = URL(string: UIApplication.openSettingsURLString) {
          openURL(url)
        }
      }  // Button

      Button("Cancel", role: .cancel) {}
    } message: {
      Text("Turn on camera access in Settings to take a photo.")
    }  // alert
    .alert("No Camera", isPresented: $viewModel.isPresentingNoCamera) {
    } message: {
      Text("This device has no camera. Choose a photo instead.")
    }  // alert
    .photosPicker(
      isPresented: $isPresentingPhotoPicker,
      selection: $selectedPhoto,
      matching: .images
    )
    .onChange(of: selectedPhoto) { _, newItem in
      guard let newItem else { return }

      Task {
        let data = try? await newItem.loadTransferable(type: Data.self)
        if let error = viewModel.cropPickedPhoto(data) {
          selectedPhoto = nil
          onError(error)
        }
      }
    }
    .fullScreenCover(
      isPresented: $viewModel.isPresentingCamera,
      onDismiss: {
        viewModel.cameraDidClose()
      },
      content: {
        CameraPickerView { viewModel.takenPhoto = $0 }
          .ignoresSafeArea()
      }
    )
    .sheet(
      item: $viewModel.photoToCrop,
      onDismiss: {
        selectedPhoto = nil
      },
      content: { pickedPhoto in
        CropImageView(
          image: pickedPhoto.image,
          cropShape: cropShape
        ) { croppedImage in
          onPick(try await viewModel.confirmCrop(croppedImage))
        }  // CropImageView
        .onChange(of: viewModel.error) { _, error in
          if let error {
            cropErrorWrapper = ErrorWrapper(error: error)
          }
        }
        .sheet(
          item: $cropErrorWrapper,
          onDismiss: { viewModel.error = nil },
          content: { wrapper in
            ErrorView(errorWrapper: wrapper)
          }
        )  // sheet
      }
    )
  }
}

#Preview("Empty and filled") {
  @Previewable @State var backContent = PhotoSlotContent.photo(
    UIImage(systemName: "medal.fill")?
      .withTintColor(.systemYellow, renderingMode: .alwaysOriginal) ?? UIImage())

  Form {
    HStack(alignment: .top, spacing: .Space.row) {
      PhotoSlot(
        content: .empty,
        imageType: .medal,
        cropShape: .square,
        title: "Front photo",
        message: """
          Lay it flat on a plain surface and shoot from straight above, or hang it on a plain \
          wall. Keep everything else out of the shot, and use even light with no flash.
          """,
        placeholderText: "Add front",
        onPick: { _ in },
        onRemove: {},
        onError: { _ in }
      )  // PhotoSlot

      PhotoSlot(
        content: backContent,
        imageType: .medal,
        cropShape: .square,
        title: "Back photo",
        onPick: { backContent = .photo($0.image) },
        onRemove: { backContent = .empty },
        onError: { _ in }
      )  // PhotoSlot
    }  // HStack
    .listRowBackground(Color.clear)
  }  // Form
}

#Preview("Without the camera") {
  Form {
    PhotoSlot(
      content: .empty,
      imageType: .avatar,
      cropShape: .circle,
      title: "Front photo",
      offersCamera: false,
      onPick: { _ in },
      onRemove: {},
      onError: { _ in }
    )  // PhotoSlot
    .frame(maxWidth: .infinity)
    .listRowBackground(Color.clear)
  }  // Form
}

#Preview("Stored photo loading and failed") {
  Form {
    HStack(alignment: .top, spacing: .Space.row) {
      PhotoSlot(
        content: .loading,
        imageType: .medal,
        cropShape: .square,
        title: "Front photo",
        placeholderText: "Add front",
        onPick: { _ in },
        onRemove: {},
        onError: { _ in }
      )  // PhotoSlot

      PhotoSlot(
        content: .failed,
        imageType: .medal,
        cropShape: .square,
        title: "Back photo",
        placeholderText: "Add back",
        onPick: { _ in },
        onRemove: {},
        onError: { _ in }
      )  // PhotoSlot
    }  // HStack
    .listRowBackground(Color.clear)

    PhotoSlot(
      content: .failed,
      imageType: .avatar,
      cropShape: .circle,
      title: "Profile photo",
      onPick: { _ in },
      onRemove: {},
      onError: { _ in }
    )  // PhotoSlot
    .frame(maxWidth: .infinity)
    .listRowBackground(Color.clear)
  }  // Form
}
