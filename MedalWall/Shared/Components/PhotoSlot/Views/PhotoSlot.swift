//
//  PhotoSlot.swift
//  MedalWall
//
//  Created by Quien on 2026-11-12.
//

import CropImage
import PhotosUI
import SwiftUI

/// A photo the user sets in a form: the photo, or a dashed slot inviting one.
///
/// Tapping it opens an alert under `title`, with `message` beneath when given: Choose Photo,
/// Take Photo while `offersCamera` is true, Remove Photo once there is a photo, and Cancel.
/// Choose Photo opens the photo library. Take Photo opens the camera once camera access allows
/// it, lets iOS ask first, or says why the camera cannot open. Either photo is then framed in
/// `cropShape`, at `outputSide` pixels when given, and the framed photo reaches `onPick`. A
/// photo that fails to load reaches `onError`.
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
  @State private var takenPhoto: UIImage?
  @State private var photoToCrop: PickedPhoto?
  @State private var viewModel = PhotoSlotViewModel()

  // MARK: - Properties
  private let photo: UIImage?
  private let imageType: ImageType
  private let cropShape: CropShape
  private let outputSide: CGFloat?
  private let title: LocalizedStringKey
  private let message: LocalizedStringKey?
  private let placeholderText: LocalizedStringKey?
  private let offersCamera: Bool
  private let onPick: (UIImage) -> Void
  private let onRemove: () -> Void
  private let onError: (AppError) -> Void

  // MARK: - Init
  /// Creates a slot showing `photo`, or the dashed slot reading `placeholderText` beneath a
  /// plus without one.
  init(
    photo: UIImage?,
    imageType: ImageType,
    cropShape: CropShape,
    outputSide: CGFloat? = nil,
    title: LocalizedStringKey,
    message: LocalizedStringKey? = nil,
    placeholderText: LocalizedStringKey? = nil,
    offersCamera: Bool = true,
    onPick: @escaping (UIImage) -> Void,
    onRemove: @escaping () -> Void,
    onError: @escaping (AppError) -> Void
  ) {
    self.photo = photo
    self.imageType = imageType
    self.cropShape = cropShape
    self.outputSide = outputSide
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
          if let photo {
            Image(uiImage: photo)
              .resizable()
              .scaledToFill()
              .background(Color.Surface.primary)
          } else {
            VStack(spacing: .Space.inline) {
              Image(systemName: "plus")

              if let placeholderText {
                Text(placeholderText)
              }
            }  // VStack
            .font(.TypeScale.headline)
            .foregroundStyle(Color.Text.primary)
          }
        }
        .clipShape(imageType.shape)
        .contentShape(imageType.shape)
        .overlay {
          if isPresentingOptions {
            imageType.shape.stroke(Color.Accent.primary, lineWidth: 2)
          } else if photo != nil {
            imageType.shape.stroke(Color.Border.primary, lineWidth: 1)
          } else {
            imageType.shape.stroke(
              Color.Border.placeholder, style: StrokeStyle(lineWidth: 1.5, dash: [6, 4]))
          }
        }
    }  // Button
    .buttonStyle(.plain)
    .accessibilityLabel(
      PhotoSlotViewModel.accessibilityLabel(
        photo: photo, title: title, placeholderText: placeholderText))
    .alert(Text(title), isPresented: $isPresentingOptions) {
      Button("Choose Photo") {
        isPresentingPhotoPicker = true
      }  // Button

      if offersCamera {
        Button("Take Photo") {
          viewModel.takePhoto()
        }  // Button
      }

      if photo != nil {
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
        if let data = try? await newItem.loadTransferable(type: Data.self),
          let image = UIImage(data: data)
        {
          photoToCrop = PickedPhoto(image: image)
        } else {
          selectedPhoto = nil
          onError(.photoDataInvalid)
        }
      }
    }
    .fullScreenCover(
      isPresented: $viewModel.isPresentingCamera,
      onDismiss: {
        if let takenPhoto { photoToCrop = PickedPhoto(image: takenPhoto) }
        takenPhoto = nil
      },
      content: {
        CameraPickerView { takenPhoto = $0 }
          .ignoresSafeArea()
      }
    )
    .sheet(
      item: $photoToCrop,
      onDismiss: {
        selectedPhoto = nil
      },
      content: { pickedPhoto in
        CropImageView(
          image: pickedPhoto.image,
          cropShape: cropShape,
          outputSide: outputSide
        ) { croppedImage in
          if let croppedImage { onPick(croppedImage) }
        }
      }
    )
  }
}

#Preview("Empty and filled") {
  @Previewable @State var backPhoto = UIImage(systemName: "medal.fill")?
    .withTintColor(.systemYellow, renderingMode: .alwaysOriginal)

  Form {
    HStack(alignment: .top, spacing: .Space.row) {
      PhotoSlot(
        photo: nil,
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
        photo: backPhoto,
        imageType: .medal,
        cropShape: .square,
        title: "Back photo",
        onPick: { backPhoto = $0 },
        onRemove: { backPhoto = nil },
        onError: { _ in }
      )  // PhotoSlot
    }  // HStack
    .listRowBackground(Color.clear)
  }  // Form
}

#Preview("Without the camera") {
  Form {
    PhotoSlot(
      photo: nil,
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
