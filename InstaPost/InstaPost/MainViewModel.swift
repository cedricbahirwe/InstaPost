//
//  MainViewModel.swift
//  InstaPost
//
//  Created by Cédric Bahirwe on 07/02/2021.
//

import Foundation
import Photos
import SwiftUI

class MainViewModel: NSObject, ObservableObject {
    @Published var profileImage: UIImage = UIImage(named: "abclo") ?? UIImage.init()
    @Published var showPicker = false

    @Published var error: (Bool, String) = (false, "")
    @Published var pickerSourceType: UIImagePickerController.SourceType = .photoLibrary
    
    func shareImage() {
        shareToInstagramStories(image: self.profileImage)
    }
        
    func selectPhotoFromGalary(){
        pickerSourceType = .photoLibrary
        showPhotoPickerUtil()
    }
    
    func capturePhotoWithCamera(){
        pickerSourceType = .camera
        showPhotoPickerUtil()
    }
    
    func shareToInstagramStories(image: UIImage) {
        // NOTE: you need a different custom URL scheme for Stories, instagram-stories, add it to your Info.plist!
        guard let instagramUrl = URL(string: "instagram-stories://share") else {
            return
        }
        
        if UIApplication.shared.canOpenURL(instagramUrl) {
            let pasterboardItems = [["com.instagram.sharedSticker.backgroundImage": image as Any]]
            UIPasteboard.general.setItems(pasterboardItems)
            UIApplication.shared.open(instagramUrl)
        } else {
            // Instagram app is not installed or can't be opened, pop up an alert
            error = (true, "Unable to open the Instagram. \nInstagram app is not installed or can't be opened")
        }
    }
    
    private func showPhotoPickerUtil() {
        if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            error = (true, "Unable to access the Camera. \nTo enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.")
            print("Access Denied")
        } else{
            showPicker.toggle()
        }
    }
    
}

extension MainViewModel: UIDocumentInteractionControllerDelegate {}
