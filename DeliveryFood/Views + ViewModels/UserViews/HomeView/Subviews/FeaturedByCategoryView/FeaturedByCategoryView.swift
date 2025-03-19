//
//  FeaturedByCategoryView.swift
//  DeliveryFood
//
//  Created by BrinyPiny on 20.01.2024.
//

import SwiftUI

struct FeaturedByCategoryView: View {
    @StateObject private var viewModel: FeaturedByCategoryViewModel
    private let foodModel: DetailFoodModel
    
    //View с загруженными данными о карточке продукта
    init(foodModel: DetailFoodModel, showError: @escaping (String) -> ()) {
        self.foodModel = foodModel
        self._viewModel = StateObject(wrappedValue: FeaturedByCategoryViewModel(showError: showError))
    }
    
    //View пустышка (во время подгрузки данных)
    init() {
        self.foodModel = DetailFoodModel.mock
        self._viewModel = StateObject(wrappedValue: FeaturedByCategoryViewModel())
    }
    
    var body: some View {
        VStack {
            RoundedRectangle(cornerRadius: 20)
                .foregroundStyle(Color.init(uiColor: UIColor.systemBackground))
                .shadow(color: .primary.opacity(0.2), radius: 5, x: 2, y: 2)
                .frame(height: 175)
                .overlay {
                    NavigationLink {
                        DetailView(foodModel: foodModel, foodImage: $viewModel.foodImage)
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
                                        viewModel.addToCartAction(foodModel: foodModel)
                                    }
                            }
                            Spacer()
                            Image(uiImage: viewModel.foodImage)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 20))
                                .redacted(reason: viewModel.isImageLoading ? .placeholder : .invalidated)
                                .animation(.easeInOut(duration: 0.2), value: viewModel.isImageLoading)
                        }
                        .padding()
                    }
                    .buttonStyle(.plain)
                }
        }
        .onAppear {
            viewModel.onAppear(foodModel: foodModel)
        }
    }
}

#Preview {
    FeaturedByCategoryView(foodModel: DetailFoodModel.mock, showError: { _ in })
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
                    .foregroundStyle(.black)
                    .opacity(0.75)
                }
            }
            .padding([.leading, .bottom], -16)
            .padding([.trailing], 32)
            .frame(height: 40)
    }
}
