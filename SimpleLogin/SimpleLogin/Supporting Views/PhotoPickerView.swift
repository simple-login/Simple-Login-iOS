//
//  PhotoPickerView.swift
//  SimpleLogin
//
//  Created by Thanh-Nhon Nguyen on 11/01/2022.
//

import SwiftUI

struct PhotoPickerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode
//    @Binding var image: UIImage?
    var onPickImage: ((UIImage) -> Void)

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .photoLibrary
        return picker
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}

extension PhotoPickerView {
    final class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: PhotoPickerView

        init(parent: PhotoPickerView) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onPickImage(image)
//                parent.image = image
            }
            parent.presentationMode.wrappedValue.dismiss()
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
