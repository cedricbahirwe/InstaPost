//
//  ViewController.swift
//  Insta
//
//  Created by Cedric Bahirwe on 11/3/20.
//  Copyright © 2020 Cedric Bahirwe. All rights reserved.
//

import UIKit
import Photos

class ViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    let imageVC = UIImagePickerController()
    var profileImage: UIImage? = UIImage(named: "apple")! {
        didSet {
            self.imageView.image = profileImage
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        self.imageView.image = profileImage
    }
    
    
    @IBAction func shareImage(_ sender: UIButton) {
        
        shareToInstagramStories(image: self.profileImage!)
    }
    @IBAction func shareFromPhone(_ sender: Any) {
        let alert = UIAlertController(title: "Select an Action", message: "", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Select Photo from gallery", style: .default, handler: {
            [weak self] (_) in
            self?.selectPhotoFromGalary()
        }))
        alert.addAction(UIAlertAction(title: "Capture Photos with camera", style: .default, handler: {
            [weak self] (_) in
            self?.capturePhotoWithCamera()
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .destructive, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func shareToInstagramFeed(image: UIImage) {
        // build the custom URL scheme
        guard let instagramUrl = URL(string: "instagram://app") else {
            return
        }
        
        // check that Instagram can be opened
        if UIApplication.shared.canOpenURL(instagramUrl) {
            // build the image data from the UIImage
            guard let imageData = image.jpegData(compressionQuality: 100) else {
                return
            }
            
            // build the file URL
            let path = (NSTemporaryDirectory() as NSString).appendingPathComponent("instagram.ig")
            let fileUrl = URL(fileURLWithPath: path)
            
            // write the image data to the file URL
            do {
                try imageData.write(to: fileUrl, options: .atomic)
            } catch {
                // could not write image data
                return
            }
            
            // instantiate a new document interaction controller
            // you need to instantiate one document interaction controller per file
            let documentController = UIDocumentInteractionController(url: fileUrl)
            documentController.delegate = self
            // the UTI is given by Instagram
            documentController.uti = "com.instagram.photo"
            
            // open the document interaction view to share to Instagram feed
            documentController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
        } else {
            // Instagram app is not installed or can't be opened, pop up an alert
        }
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
        }
    }
    
    
    // NOTE: Assumes that you've added UIDocumentInteractionControllerDelegate to your view controller class
    
    func shareFileUrlOnInstagram(fileUrl: URL) {
        let documentController = UIDocumentInteractionController(url: fileUrl)
        // the UTI is given by Instagram
        documentController.uti = "com.instagram.photo"
        
        // open the document interaction view to share to Instagram
        documentController.presentOpenInMenu(from: self.view.frame, in: self.view, animated: true)
    }
    
    private func selectPhotoFromGalary(){
        imageVC.sourceType = UIImagePickerController.SourceType.photoLibrary
        showPhotoPickerUtil()
    }
    
    private func capturePhotoWithCamera(){
        imageVC.sourceType = UIImagePickerController.SourceType.camera
        showPhotoPickerUtil()
    }
    
    private func showPhotoPickerUtil(){
        if AVCaptureDevice.authorizationStatus(for: .video) == .denied {
            let alert = AlertDailog(title: "Unable to access the Camera", message: "To enable access, go to Settings > Privacy > Camera and turn on Camera access for this app.")
            self.present(alert.getSimpleAlertDailog(actionName: "Ok"), animated: true, completion: nil)
        } else{
            showCameraVC()
        }
    }
    
    private func showCameraVC(){
        DispatchQueue.main.async {
            self.imageVC.delegate = self
            self.imageVC.allowsEditing = false
            self.present(self.imageVC, animated: true, completion: nil)
        }
    }
    
}


extension ViewController: UIDocumentInteractionControllerDelegate { }

extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let image = info[.originalImage] as? UIImage{
            self.profileImage = image
            imageVC.dismiss(animated: true, completion: nil)
        }
    }
}


class AlertDailog{
    private var title: String
    private var message: String?
    init(title: String, message: String?){
        self.title = title
        self.message = message
    }
    
    func getSimpleAlertDailog(actionName: String) -> UIAlertController{
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okButton = UIAlertAction(title: actionName, style: .destructive, handler: nil)
        alert.addAction(okButton)
        return alert
    }
}
