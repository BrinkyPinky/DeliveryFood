//
//  CategoryView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 20.01.2024.
//

import SwiftUI

struct CategoryView: View {
    let category: CategoryModel
    let isPicked: Bool
    @State private var image = UIImage()
    
    var body: some View {
        VStack {
            Image(uiImage: image)
                .resizable()
                .frame(width: 125, height: 125)
                .background {
                    Image(uiImage: image)
                        .resizable()
                        .frame(width: 125, height: 125)
                        .opacity(0.7)
                        .blur(radius: 20)
                        .offset(x: 10.0, y: 10.0)
                }
                
            HStack {
                Text(category.name)
                    .font(.system(size: 18))
                    .fontWeight(isPicked ? .bold : .regular)
                if isPicked {
                    Image(systemName: "arrow.right")
                        .bold()
                        .opacity(isPicked ? 1 : 0)
                }
            }
        }
        .background {
            RoundedRectangle(cornerRadius: 20)
                .frame(width: 125, height: 175)
                .foregroundStyle(isPicked ? Color.greenForSelecting : Color.init(uiColor: UIColor.systemBackground))
                .shadow(color: .primary.opacity(0.2), radius: 5, x: 2, y: 2)
        }
        .onAppear {
            FirebaseStorageManager.shared.downloadImage(withURL: category.url) { data in
                guard data != nil else {
                    image = UIImage(systemName: "xmark.diamond")!
                    return
                }
                
                image = UIImage(data: data!)!
            }
        }
        .animation(.easeInOut(duration: 0.15), value: isPicked)
    }
}

#Preview {
    CategoryView(category: CategoryModel(id: 1, url: "gs://deliveryfood-db5c8.appspot.com/categories/pizza.png", name: "Pizza"), isPicked: true)
}
