//
//  PickImageView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 19.03.2025.
//

import SwiftUI

struct PickImageView: View {
    @Binding var image: UIImage
    @Binding var isImagePickerPresented: Bool
    
    var body: some View {
        ZStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: UIScreen.main.bounds.width/2, height: UIScreen.main.bounds.width/2)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .overlay {
                    RoundedRectangle(cornerRadius: 20)
                        .opacity(0.3)
                        .foregroundStyle(.black)
                }
                .background {
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(lineWidth: 2)
                        .opacity(0.1)
                }
                .padding()
            
            Image(systemName: "square.and.arrow.down")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50,height: 50)
                .foregroundStyle(.white)
        }
        .onTapGesture {
            isImagePickerPresented = true
        }
    }
}
