//
//  FeaturedByCategoryView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 20.01.2024.
//

import SwiftUI

struct FeaturedByCategoryView: View {
    @StateObject private var viewModel = FeaturedByCategoryViewModel()
    @State private var foodImage = UIImage()
    
    let foodModel: DetailFoodModel
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Color.init(uiColor: UIColor.systemBackground))
                .shadow(color: .primary.opacity(0.2), radius: 5, x: 2, y: 2)
                .frame(height: 175)
                .overlay {
                    NavigationLink {
                        DetailView(foodModel: foodModel, foodImage: $foodImage)
                            .toolbar(.hidden)
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(foodModel.name)
                                    .font(.system(size: 20, weight: .bold, design: .rounded))
                                Text(foodModel.text1)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.secondary)
                                
                                Spacer()
                                
                                addToCartWithPriceButtonView(foodModel: foodModel, viewModel: viewModel)
                                    .onTapGesture {
                                        viewModel.startAddToCartAnimation()
                                    }
                            }
                            Spacer()
                            Image(uiImage: foodImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                        }
                        .padding()
                    }
                    .buttonStyle(.plain)
                }
        }
        .onAppear {
            FirebaseStorageManager.shared.downloadImage(withURL: foodModel.imageURL) { data in
                guard data != nil else {
                    foodImage = UIImage(systemName: "xmark")!
                    return
                }
                
                foodImage = UIImage(data: data!)!
            }
        }
    }
}

#Preview {
    FeaturedByCategoryView(foodModel: DetailFoodModel(
        heading1: "",
        heading2: "",
        heading3: "",
        text1: "200gr / 430kcal",
        text2: "",
        text3: "",
        imageURL: "gs://deliveryfood-db5c8.appspot.com/food/burgers/Chickenburger.png",
        ingredients: [],
        name: "Chefburger ricececerqwqr",
        price: 1.20,
        foodID: "burger1"
    ))
}

struct addToCartWithPriceButtonView: View {
    let foodModel: DetailFoodModel
    @ObservedObject var viewModel: FeaturedByCategoryViewModel
    
    var body: some View {
        Rectangle()
            .clipShape(
                .rect(
                    topLeadingRadius: 0,
                    bottomLeadingRadius: 20,
                    bottomTrailingRadius: 0,
                    topTrailingRadius: 20
                )
            )
            .foregroundStyle(.yellow)
            .overlay {
                HStack {
                    ZStack {
                        Text("$ \(String(format: "%.2f", foodModel.price))")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .opacity(viewModel.animationMainTextOpacity)
                        Image(systemName: "checkmark")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .scaleEffect(
                                CGSize(
                                    width: viewModel.animationSuccessTextScale,
                                    height: viewModel.animationSuccessTextScale
                                )
                            )
                    }
                }
            }
            .padding([.leading, .bottom], -16)
            .padding([.trailing], 32)
            .frame(height: 40)
    }
}
