//
//  ImagePickerView.swift
//  InstaPost
//
//  Created by Cédric Bahirwe on 06/02/2021.
//

import Foundation
import SwiftUI
import UIKit
import Photos

struct ImagePicker: UIViewControllerRepresentable {
    
    
    @Environment(\.presentationMode) var presentationMode
    @Binding var image: UIImage
    var onFinish: (() -> ()) = {}
    var onCancel: (() -> ()) = {}
    @Binding var sourceType: UIImagePickerController.SourceType
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {

    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
            
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onCancel()
            parent.presentationMode.wrappedValue.dismiss()
        }
        
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
            
                let imgData = Data(uiImage.jpegData(compressionQuality: 1)!)
                let imageSize: Int = imgData.count
                print("actual size of image in KB: %f ", Double(imageSize) / 1000.0)
                parent.image = uiImage
            }
            parent.onFinish()

            parent.presentationMode.wrappedValue.dismiss()
        }
        

    }
    
}

extension ImagePicker.Coordinator: UIDocumentInteractionControllerDelegate { }
