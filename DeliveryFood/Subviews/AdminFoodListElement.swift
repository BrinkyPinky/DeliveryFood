//
//  AdminFoodListElement.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 19.03.2025.
//

import SwiftUI

struct AdminFoodListElement: View {
    let foodModel: DetailFoodModel
    let showErrorWithMessage: (String) -> Void
    @State private var isImageLoading = true
    @State var image = UIImage()

    var body: some View {
        HStack {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 50, height: 50)
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .redacted(reason: isImageLoading ? .placeholder : .invalidated)

            Text(foodModel.name)
                .bold()
        }
        .onAppear {
            FirebaseStorageManager.shared.downloadImage(
                withPath: "food/\(foodModel.foodID)"
            ) { result in
                switch result {
                case .success(let success):
                    guard let img = UIImage(data: success) else {
                        showErrorWithMessage(
                            "Failed to convert the photo to the desired format")
                        return
                    }
                    image = img
                    isImageLoading = false
                case .failure(let failure):
                    showErrorWithMessage(failure.localizedDescription)
                }
            }
        }
    }
}
