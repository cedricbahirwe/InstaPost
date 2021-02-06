//
//  ContentView.swift
//  InstaPost
//
//  Created by Cédric Bahirwe on 06/02/2021.
//

import SwiftUI
import Photos
struct ContentView: View {
    @ObservedObject var vm = MainViewModel()
    let size = UIScreen.main.bounds.size
    let greenColor = Color(red: -0.388, green: 0.862, blue: 0.593)
    
    @State private var showSheet = false

    var body: some View {
        ZStack {
            
            Color(.secondarySystemBackground)
                .colorScheme(.dark)
                .edgesIgnoringSafeArea(.all)
            
            VStack(spacing: 20) {
                Image(uiImage: vm.profileImage)
                    .resizable()
                    .aspectRatio(1/1, contentMode: .fit)
                    .frame(maxWidth: .infinity)
//                    .aspectRatio(contentMode: .fit)
                    .frame(height: size.height/3)
                    .background(
                        ZStack {
                            Color.secondary
                            Text("Picture")
                                .font(.title)
                                .foregroundColor(greenColor)
                        }
                    )
                
                Button(action: vm.shareImage) {
                    Text("Share Picture")
                        .font(.caption)
                        .foregroundColor(greenColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color.black)
                }
                
                Button(action: {
                    showSheet.toggle()
                }, label: {
                    Text("Select Image")
                        .font(.caption)
                        .foregroundColor(greenColor)
                        .frame(maxWidth: .infinity)
                        .frame(height: 45)
                        .background(Color.black)
                })
                
                Spacer()
                Group  {
                    if #available(iOS 14.0, *) {
                        Link(destination: URL(string: "https://github.com/cedricbahirwe")!, label: {
                            Text("Made with ❤️ By Cédric Bahirwe")
                        })
                    } else {
                        Text("Made with ❤️ By Cédric Bahirwe")
                    }
                }
                .foregroundColor(greenColor)
                .padding(.bottom, 20)
                
            }
            
            .padding()
            .sheet(isPresented: $vm.showPicker, content: {
                ImagePicker(image: $vm.profileImage, sourceType: $vm.pickerSourceType)
            })
            .actionSheet(isPresented: $showSheet, content: {
                ActionSheet(
                    title: Text("Pick one option"),
                    message: nil,
                    buttons: [
                        .default(Text("Select Photo from gallery"), action: vm.selectPhotoFromGalary),
                        .default(Text("Capture Photo with camera"), action: vm.capturePhotoWithCamera),
                        .destructive(Text("Cancel"))
                    ])
            })
            
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

class MainViewModel: NSObject, ObservableObject {
    @Published var profileImage: UIImage = UIImage.init()
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
