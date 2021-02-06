//
//  ContentView.swift
//  InstaPost
//
//  Created by Cédric Bahirwe on 06/02/2021.
//

import SwiftUI

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
                    .aspectRatio(contentMode: .fit)
                    .padding(10)
                    .frame(maxWidth: .infinity)
                    //                    .aspectRatio(contentMode: .fit)
                    
                    .frame(height: size.height/3)
                    .background(Color.secondary)
                
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
        .colorScheme(.light)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
