//
//  CameraPickerView.swift
//  MedalWall
//
//  Created by Quien on 2026-11-03.
//

import SwiftUI
import UIKit

/// The system camera, with no guide overlay, handing back the photo taken.
///
/// SwiftUI has no camera picker, so this wraps `UIImagePickerController`. Present it only when
/// `CameraAccess.current` is `granted`: on a device with no camera, the controller raises an
/// exception.
struct CameraPickerView: UIViewControllerRepresentable {
  @Environment(\.dismiss) private var dismiss

  let onCapture: (UIImage) -> Void

  func makeUIViewController(context: Context) -> UIImagePickerController {
    let picker = UIImagePickerController()
    picker.sourceType = .camera
    picker.delegate = context.coordinator
    return picker
  }

  func updateUIViewController(_ picker: UIImagePickerController, context: Context) {}

  func makeCoordinator() -> Coordinator {
    Coordinator(onCapture: onCapture, dismiss: dismiss)
  }

  /// Hands the photo taken back and closes the camera, or just closes it on cancel.
  final class Coordinator: NSObject, UIImagePickerControllerDelegate,
    UINavigationControllerDelegate
  {
    private let onCapture: (UIImage) -> Void
    private let dismiss: DismissAction

    init(onCapture: @escaping (UIImage) -> Void, dismiss: DismissAction) {
      self.onCapture = onCapture
      self.dismiss = dismiss
    }

    /// Hands back the photo just taken.
    func imagePickerController(
      _ picker: UIImagePickerController,
      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]
    ) {
      if let photo = info[.originalImage] as? UIImage {
        onCapture(photo)
      }
      dismiss()
    }

    /// Closes the camera without a photo.
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
      dismiss()
    }
  }
}

#Preview {
  if UIImagePickerController.isSourceTypeAvailable(.camera) {
    CameraPickerView(onCapture: { _ in })
  } else {
    Text(verbatim: "This device has no camera.")
  }
}
